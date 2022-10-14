# Linode API token.
variable "linode_token" {}

# Default URL of the CI repository.
variable "demo_repo_url" {
  default = "https://raw.githubusercontent.com/fvilarinho/akamai-linode-demo/main"
}

# Default label.
variable "demo_label" {
  default = "demo"
}
# Default public key to be installed in the cluster nodes.
variable "demo_public_key" {
  default = "~/.ssh/id_rsa.pub"
}
# Default private key to be used to connect in the cluster nodes.
variable "demo_private_key" {
  default = "~/.ssh/id_rsa"
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

# Default Akamai credentials filename location.
variable "akamai_credentials_filename" {
  default = "~/.edgerc"
}
# Default Akamai credentials section.
variable "akamai_credentials_section" {
  default = "default"
}
# Default Akamai group.
variable "akamai_group_id" {
  default = "grp_139286"
}
# Default Akamai contract.
variable "akamai_contract_id" {
  default = "ctr_3-1A42HS1"
}
# Default Akamai product.
variable "akamai_product_id" {
  default = "prd_Fresca"
}
# Default Akamai property.
variable "akamai_property_id" {
  default = "phonebook.akau.devops.akademo.it"
}
# Default Akamai Edge Hostname.
variable "akamai_property_edgehostname" {
  default = "devops.akademo.it.edgesuite.net"
}
# Default Akamai notification email.
variable "akamai_notification_email" {
  default = "fvilarin@akamai.com"
}

# Akamai network to be used in the property activation.
variable "akamai_property_activation_network"{
}
# Activation notes.
variable "akamai_property_activation_notes" {
}