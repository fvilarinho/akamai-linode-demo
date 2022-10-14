variable "linode_token" {}

variable "demo_repo_branch" {
  default = "main"
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