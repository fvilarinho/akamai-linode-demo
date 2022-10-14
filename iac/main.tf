terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
    }
    akamai = {
      source = "akamai/akamai"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

provider "akamai" {
  edgerc         = var.akamai_credentials_filename
  config_section = var.akamai_credentials_section
}

resource "linode_sshkey" "demo" {
  label   = var.demo_label
  ssh_key = chomp(file(var.demo_public_key))
}

resource "linode_instance" "demo-node-manager" {
  label           = var.demo_node_manager_label
  image           = var.demo_node_manager_os
  region          = var.demo_node_manager_region
  type            = var.demo_node_manager_type
  authorized_keys = [
    linode_sshkey.demo.ssh_key
  ]
  private_ip      = true

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname ${var.demo_node_manager_label}",
      "pkill -9 dpkg; pkill -9 apt; apt -y update; apt -y upgrade",
      "apt -y install ca-certificates curl wget htop unzip dnsutils net-tools vim",
      "export K3S_TOKEN=${var.linode_token}",
      "curl -sfL https://get.k3s.io | sh -"
    ]

    connection {
      type        = "ssh"
      host        = self.ip_address
      user        = "root"
      agent       = false
      private_key = chomp(file(var.demo_private_key))
    }
  }
}

resource "linode_instance" "demo-node-worker" {
  label           = var.demo_node_worker_label
  image           = var.demo_node_worker_os
  region          = var.demo_node_worker_region
  type            = var.demo_node_worker_type
  authorized_keys = [
    linode_sshkey.demo.ssh_key
  ]
  private_ip      = true
  depends_on      = [
    linode_instance.demo-node-manager
  ]

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname ${var.demo_node_worker_label}",
      "pkill -9 dpkg; pkill -9 apt; apt -y update; apt -y upgrade",
      "apt -y install ca-certificates curl wget htop unzip dnsutils net-tools vim",
      "curl -sfL https://get.k3s.io | K3S_URL=https://${linode_instance.demo-node-manager.ip_address}:6443 K3S_TOKEN=${var.linode_token} sh -"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      agent       = false
      private_key = chomp(file(var.demo_private_key))
      host        = self.ip_address
    }
  }
}

resource "null_resource" "apply-stack" {
  triggers = {
    always_run = "${timestamp()}"
  }

  connection {
    type        = "ssh"
    host        = linode_instance.demo-node-manager.ip_address
    user        = "root"
    agent       = false
    private_key = chomp(file(var.demo_private_key))
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl label node ${var.demo_node_manager_label} kubernetes.io/role=manager",
      "kubectl label node ${var.demo_node_worker_label} kubernetes.io/role=worker",
      "wget -O .env ${var.demo_repo_url}/iac/.env",
      "wget -O ./kubernetes.yml ${var.demo_repo_url}/iac/kubernetes.yml",
      "wget -O ./applyStack.sh ${var.demo_repo_url}/iac/applyStack.sh",
      "chmod +x ./applyStack.sh",
      "./applyStack.sh",
      "rm -f ./env",
      "rm -f ./kubernetes.yml",
      "rm -f ./applyStack.sh"
    ]
  }

  depends_on = [
    linode_instance.demo-node-manager,
    linode_instance.demo-node-worker
  ]
}

resource "null_resource" "setup-property" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "./setupProperty.sh ${linode_instance.demo-node-manager.ip_address}"
  }

  depends_on = [
    null_resource.apply-stack
  ]
}

data "akamai_property_rules_template" "demo-property" {
  template_file = abspath("./property-snippets/main.json")

  depends_on = [
    null_resource.setup-property
  ]
}

resource "akamai_property" "demo-property" {
  name        = var.akamai_property_id
  contract_id = var.akamai_contract_id
  group_id    = var.akamai_group_id
  product_id  = var.akamai_product_id
  rule_format = "v2021-09-22"
  hostnames {
    cname_from             = var.akamai_property_id
    cname_to               = var.akamai_property_edgehostname
    cert_provisioning_type = "CPS_MANAGED"
  }
  rules = data.akamai_property_rules_template.demo-property.json
  depends_on = [
    null_resource.setup-property
  ]
}

resource "akamai_property_activation" "demo-property" {
  property_id = akamai_property.demo-property.id
  version     = akamai_property.demo-property.latest_version
  network     = upper(var.akamai_property_activation_network)
  note        = var.akamai_property_activation_notes
  contact     = [ var.akamai_notification_email ]
}
