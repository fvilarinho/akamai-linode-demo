variable "linode_token" {}

variable "demo_repo_url" {
  default = "https://raw.githubusercontent.com/fvilarinho/akamai-linode-demo/main"
}

variable "demo_label" {
  default = "demo"
}
variable "demo_public_key" {
  default = "~/.ssh/id_rsa.pub"
}
variable "demo_private_key" {
  default = "~/.ssh/id_rsa"
}

variable "demo_node_manager_label" {
  default = "demo-node-manager"
}
variable "demo_node_manager_type" {
  default = "g6-standard-2"
}
variable "demo_node_manager_region" {
  default = "us-east"
}
variable "demo_node_manager_os" {
  default = "linode/debian11"
}

variable "demo_node_worker_label" {
  default = "demo-node-worker"
}
variable "demo_node_worker_type" {
  default = "g6-standard-2"
}
variable "demo_node_worker_region" {
  default = "us-east"
}
variable "demo_node_worker_os" {
  default = "linode/debian11"
}

variable "akamai_credentials_filename" {
  default = "~/.edgerc"
}
variable "akamai_credentials_section" {
  default = "default"
}
variable "akamai_group_id" {
  default = "grp_139286"
}
variable "akamai_contract_id" {
  default = "ctr_3-1A42HS1"
}
variable "akamai_product_id" {
  default = "prd_Fresca"
}
variable "akamai_property_id" {
  default = "phonebook.akau.devops.akademo.it"
}
variable "akamai_property_edgehostname" {
  default = "devops.akademo.it.edgesuite.net"
}
variable "akamai_notification_email" {
  default = "fvilarin@akamai.com"
}
variable "akamai_property_activation_network"{
}
variable "akamai_property_activation_notes" {
}