terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
    }
  }
}

provider "linode" {
  token = var.linode_token
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
  authorized_keys = [ linode_sshkey.demo.ssh_key ]

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
  authorized_keys = [ linode_sshkey.demo.ssh_key ]
  depends_on      = [ linode_instance.demo-node-manager ]

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
      "mkdir ./iac",
      "wget -O ./iac/.env https://github.com/fvilarinho/akamai-linode-demo/blob/${var.demo_repo_branch}/iac/.env",
      "wget -O ./iac/kubernetes.yml https://github.com/fvilarinho/akamai-linode-demo/blob/${var.demo_repo_branch}/iac/kubernetes.yml",
      "wget https://github.com/fvilarinho/akamai-linode-demo/blob/${var.demo_repo_branch}/apply-stack.sh",
      "chmod +x ./apply-stack.sh",
      "./apply-stack.sh"
    ]
  }

  depends_on = [
    linode_instance.demo-node-manager,
    linode_instance.demo-node-worker
  ]
}

