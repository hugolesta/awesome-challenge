locals {
  tags = {
    name           = lower(var.env["name"])
    prefix         = lower(var.env["prefix"])
    environment    = lower(var.env["environment"])
    role           = lower(var.env["role"])
    costCenter     = lower(var.env["costCenter"])
    tagVersion     = lower(var.env["tagVersion"])
    owner          = lower(var.env["owner"])
    project        = lower(var.env["project"])
    expirationDate = lower(var.env["expirationDate"])
    id = lower(
      var.env["name"] == "" ? join(var.env["delimiter"], compact([var.env["prefix"], var.env["role"]])) : var.env["name"]
    )
  }
}
