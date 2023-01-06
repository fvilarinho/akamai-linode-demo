# Akamai EdgeGrid definition.
provider "akamai" {
  edgerc         = ".edgerc"
  config_section = "default"
}

resource "akamai_cp_code" "application" {
  name        = var.akamai.property.id
  contract_id = var.akamai.contract
  group_id    = var.akamai.group
  product_id  = var.akamai.product
}

# Definition of the Akamai property rule tree.
data "akamai_property_rules_template" "application" {
  template_file = abspath("property-snippets/main.json")
  depends_on    = [ linode_nodebalancer.application ]

  # Set the Origin Hostname pointing to cluster load balancer.
  variables {
    name  = "originHostname"
    type  = "string"
    value = linode_nodebalancer.application.hostname
  }

  # Set the CPCode.
  variables {
    name  = "cpCode"
    type  = "number"
    value = replace(akamai_cp_code.application.id, "cpc_", "")
  }
}

# Definition of the Akamai property configuration.
resource "akamai_property" "application" {
  name        = var.akamai.property.id
  contract_id = var.akamai.contract
  group_id    = var.akamai.group
  product_id  = var.akamai.product
  rules       = data.akamai_property_rules_template.application.json
  depends_on  = [ linode_nodebalancer.application ]

  hostnames {
    cname_from             = var.akamai.property.id
    cname_to               = var.akamai.property.edgeHostname
    cert_provisioning_type = "CPS_MANAGED"
  }
}

resource "akamai_property_activation" "application" {
  property_id                    = akamai_property.application.id
  version                        = akamai_property.application.latest_version
  contact                        = [ var.akamai.email ]
  auto_acknowledge_rule_warnings = true
  depends_on                     = [ akamai_property.application ]
}