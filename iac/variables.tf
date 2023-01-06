variable "application" {
  default = {
    "label": "demo"
  }
}

variable "linode" {
  default = {
    "region": "us-east",
    "os": "linode/debian11",
    "manager": {
      "label": "demo-node-manager",
      "type": "g6-standard-2"
    },
    "worker": {
      "label": "demo-node-worker",
      "type": "g6-standard-2"
    }
  }
}

# Linode API token.
variable "linode_token" {}
# Public key to be installed in the cluster nodes.
variable "linode_public_key" {}
# Private key to be used to connect in the cluster nodes.
variable "linode_private_key" {}

variable "akamai" {
  default = {
    "account": "1-6JHGX"
    "contract": "ctr_1-1NC95D"
    "group": "grp_218127",
    "product": "prd_Fresca",
    "email": "fvilarin@akamai.com",
    "property": {
      "id": "demo.vila.net.br",
      "edgeHostname": "vila.net.br.edgesuite.net"
    }
  }
}