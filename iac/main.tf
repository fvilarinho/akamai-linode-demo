# Required providers.
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

# Linode API token definition.
provider "linode" {
  token = var.linode_token
}

# Akamai credentials definition.
provider "akamai" {
  edgerc         = var.akamai_credentials_filename
  config_section = var.akamai_credentials_section
}

# Create a public key to be used by the cluster nodes.
resource "linode_sshkey" "demo" {
  label   = var.demo_label
  ssh_key = chomp(file(var.demo_public_key))
}

# Create the manager node of the cluster.
resource "linode_instance" "demo-node-manager" {
  label           = var.demo_node_manager_label
  image           = var.demo_node_manager_os
  region          = var.demo_node_manager_region
  type            = var.demo_node_manager_type
  private_ip      = true
  authorized_keys = [ linode_sshkey.demo.ssh_key ]

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      type        = "ssh"
      host        = self.ip_address
      user        = "root"
      agent       = false
      private_key = chomp(file(var.demo_private_key))
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${var.demo_node_manager_label}",
      "pkill -9 dpkg; pkill -9 apt; apt -y update; apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim",
      "export K3S_TOKEN=${var.linode_token}",
      "curl -sfL https://get.k3s.io | sh -"
    ]
  }
}

# Create the worker node of the cluster.
resource "linode_instance" "demo-node-worker" {
  label           = var.demo_node_worker_label
  image           = var.demo_node_worker_os
  region          = var.demo_node_worker_region
  type            = var.demo_node_worker_type
  private_ip      = true
  authorized_keys = [ linode_sshkey.demo.ssh_key ]
  depends_on      = [ linode_instance.demo-node-manager ]

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      type        = "ssh"
      user        = "root"
      agent       = false
      private_key = chomp(file(var.demo_private_key))
      host        = self.ip_address
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${var.demo_node_worker_label}",
      "pkill -9 dpkg; pkill -9 apt; apt -y update; apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim",
      "curl -sfL https://get.k3s.io | K3S_URL=https://${linode_instance.demo-node-manager.ip_address}:6443 K3S_TOKEN=${var.linode_token} sh -"
    ]
  }
}

# Apply the services stack in the cluster.
resource "null_resource" "apply-stack" {
  # Trigger definition to execute.
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "remote-exec" {
    # Manager node connection definition.
    connection {
      type        = "ssh"
      host        = linode_instance.demo-node-manager.ip_address
      user        = "root"
      agent       = false
      private_key = chomp(file(var.demo_private_key))
    }

    # Installation script.
    inline = [
      "mkdir iac",
      "wget -qO iac/.env ${var.demo_repo_url}/iac/.env",
      "wget -qO iac/kubernetes.yml ${var.demo_repo_url}/iac/kubernetes.yml",
      "wget -qO applyStack.sh ${var.demo_repo_url}/applyStack.sh",
      "chmod +x applyStack.sh",
      "./applyStack.sh ${linode_instance.demo-node-manager.label} ${linode_instance.demo-node-worker.label}",
      "rm -rf iac",
      "rm -f applyStack.sh"
    ]
  }

  depends_on = [
    linode_instance.demo-node-manager,
    linode_instance.demo-node-worker
  ]
}

# Create the cluster load balancer instance.
resource "linode_nodebalancer" "demo" {
  label      = var.demo_label
  region     = var.demo_loadbalancer_region
  depends_on = [ null_resource.apply-stack ]
}

# Create the cluster load balancer configuration.
resource "linode_nodebalancer_config" "demo" {
  nodebalancer_id = linode_nodebalancer.demo.id
  port            = 80
  protocol        = "http"
  check           = "http"
  check_path      = "/"
  check_attempts  = 3
  check_timeout   = 30
  stickiness      = "http_cookie"
  algorithm       = "source"
  depends_on      = [ linode_nodebalancer.demo ]
}

# Add manager node in cluster load balancer.
resource "linode_nodebalancer_node" "demo-node-manager" {
  label           = linode_instance.demo-node-manager.label
  nodebalancer_id = linode_nodebalancer.demo.id
  config_id       = linode_nodebalancer_config.demo.id
  address         = "${linode_instance.demo-node-manager.private_ip_address}:80"
  weight          = 50
  depends_on      = [ linode_nodebalancer_config.demo ]
}

# Add worker node in cluster load balancer.
resource "linode_nodebalancer_node" "demo-node-worker" {
  label           = linode_instance.demo-node-worker.label
  nodebalancer_id = linode_nodebalancer.demo.id
  config_id       = linode_nodebalancer_config.demo.id
  address         = "${linode_instance.demo-node-worker.private_ip_address}:80"
  weight          = 50
  depends_on      = [ linode_nodebalancer_config.demo ]
}

# Definition of the Akamai property ruletree.
data "akamai_property_rules_template" "demo" {
  template_file = abspath("property-snippets/main.json")
  depends_on    = [ linode_nodebalancer.demo ]

  # Set the Origin Hostname pointing to cluster load balancer hostname.
  variables {
    name = "originHostname"
    type = "string"
    value = linode_nodebalancer.demo.hostname
  }
}

# Definition of the Akamai property configuration.
resource "akamai_property" "demo" {
  name        = var.akamai_property_id
  contract_id = var.akamai_contract_id
  group_id    = var.akamai_group_id
  product_id  = var.akamai_product_id
  rules       = data.akamai_property_rules_template.demo.json
  depends_on  = [ linode_nodebalancer.demo ]

  hostnames {
    cname_from             = var.akamai_property_id
    cname_to               = var.akamai_property_edgehostname
    cert_provisioning_type = "CPS_MANAGED"
  }
}

# Activate the Akamai property.
resource "akamai_property_activation" "demo" {
  property_id = akamai_property.demo.id
  version     = akamai_property.demo.latest_version
  network     = upper(var.akamai_property_activation_network)
  contact     = [ var.akamai_notification_email ]
  note        = var.akamai_property_activation_notes
  depends_on  = [ akamai_property.demo ]
}