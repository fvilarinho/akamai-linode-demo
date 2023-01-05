# Linode API token.
variable "linode_token" {}
# Public key to be installed in the cluster nodes.
variable "linode_public_key" {}
# Private key to be used to connect in the cluster nodes.
variable "linode_private_key" {}

# Default label.
variable "demo_label" {
  default = "demo"
}
# Default URL of the CI repository.
variable "demo_repo_url" {
  default = "https://raw.githubusercontent.com/fvilarinho/akamai-linode-demo/main"
}

# Default load balancer region.
variable "demo_loadbalancer_region" {
  default = "us-east"
}

# Default label of the manager node.
variable "demo_node_manager_label" {
  default = "demo-node-manager"
}
# Default type of the manager node.
variable "demo_node_manager_type" {
  default = "g6-standard-2"
}
# Default region of the manager node.
variable "demo_node_manager_region" {
  default = "us-east"
}
# Default operating system of the manager node.
variable "demo_node_manager_os" {
  default = "linode/debian11"
}

# Default label of the worker node.
variable "demo_node_worker_label" {
  default = "demo-node-worker"
}
# Default type of the worker node.
variable "demo_node_worker_type" {
  default = "g6-standard-2"
}
# Default region of the worker node.
variable "demo_node_worker_region" {
  default = "us-east"
}
# Default operating system of the worker node.
variable "demo_node_worker_os" {
  default = "linode/debian11"
}

# Default Akamai group.
variable "akamai_group_id" {
  default = "grp_218127"
}
# Default Akamai contract.
variable "akamai_contract_id" {
  default = "ctr_1-1NC95D"
}
# Default Akamai product.
variable "akamai_product_id" {
  default = "prd_Fresca"
}
# Default Akamai property.
variable "akamai_property_id" {
  default = "demo.vila.net.br"
}
# Default Akamai Edge Hostname.
variable "akamai_property_edgehostname" {
  default = "vila.net.br.edgesuite.net"
}
# Notes to be used in the property activation.
variable "akamai_property_activation_notes"{
  default = ""
}
# Store the Akamai property activation notes.
variable "akamai_property_activation_notes_filename" {
  default = ".akamai_property_activation_notes"
}
# Last notes of the property activation.
variable "akamai_property_last_activation_notes"{
  default = ""
}
# Default Akamai activation email.
variable "akamai_property_activation_email" {
  default = "fvilarin@akamai.com"
}