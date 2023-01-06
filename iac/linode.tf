# Linode API token definition.
provider "linode" {
  token = var.linode_token
}

# Create a public key to be used by the cluster nodes.
resource "linode_sshkey" "application" {
  label   = var.application.label
  ssh_key = var.linode_public_key
}

# Create the manager node of the cluster.
resource "linode_instance" "manager" {
  label           = var.linode.manager.label
  type            = var.linode.manager.type
  image           = var.linode.os
  region          = var.linode.region
  private_ip      = true
  authorized_keys = [ linode_sshkey.application.ssh_key ]

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      type        = "ssh"
      agent       = false
      host        = self.ip_address
      user        = "root"
      private_key = var.linode_private_key
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${var.linode.manager.label}",
      "pkill -9 dpkg; pkill -9 apt; apt -y update; apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim",
      "export K3S_TOKEN=${var.linode_token}",
      "curl -sfL https://get.k3s.io | sh -"
    ]
  }
}

# Create the worker node of the cluster.
resource "linode_instance" "worker" {
  label           = var.linode.worker.label
  type            = var.linode.worker.type
  image           = var.linode.os
  region          = var.linode.region
  private_ip      = true
  authorized_keys = [ linode_sshkey.application.ssh_key ]
  depends_on      = [ linode_instance.manager ]

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      type        = "ssh"
      agent       = false
      host        = self.ip_address
      user        = "root"
      private_key = var.linode_private_key
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${var.linode.worker.label}",
      "pkill -9 dpkg; pkill -9 apt; apt -y update; apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim",
      "curl -sfL https://get.k3s.io | K3S_URL=https://${linode_instance.manager.ip_address}:6443 K3S_TOKEN=${var.linode_token} sh -"
    ]
  }
}

# Create the cluster load balancer instance.
resource "linode_nodebalancer" "application" {
  label      = var.application.label
  region     = var.linode.region
  depends_on = [
    linode_instance.manager,
    linode_instance.worker
  ]
}

# Create the cluster load balancer configuration.
resource "linode_nodebalancer_config" "application" {
  nodebalancer_id = linode_nodebalancer.application.id
  port            = 80
  protocol        = "http"
  check           = "http"
  check_path      = "/"
  check_attempts  = 3
  check_timeout   = 30
  stickiness      = "http_cookie"
  algorithm       = "source"
  depends_on      = [ linode_nodebalancer.application ]
}

# Add manager node in cluster load balancer.
resource "linode_nodebalancer_node" "manager" {
  label           = linode_instance.manager.label
  nodebalancer_id = linode_nodebalancer.application.id
  config_id       = linode_nodebalancer_config.application.id
  address         = "${linode_instance.manager.private_ip_address}:80"
  weight          = 50
  depends_on      = [ linode_nodebalancer_config.application ]
}

# Add worker node in cluster load balancer.
resource "linode_nodebalancer_node" "worker" {
  label           = linode_instance.worker.label
  nodebalancer_id = linode_nodebalancer.application.id
  config_id       = linode_nodebalancer_config.application.id
  address         = "${linode_instance.worker.private_ip_address}:80"
  weight          = 50
  depends_on      = [ linode_nodebalancer_config.application ]
}