data "tfe_outputs" "vpc" {
  organization = "JaburoTV"
  workspace    = "vpc-${var.environment_name}"
}

locals {
  vpc_id                 = nonsensitive(data.tfe_outputs.vpc.values.vpc_id)
  public_subnet_ids      = nonsensitive(data.tfe_outputs.vpc.values.public_subnet_ids)
  private_subnet_ids     = nonsensitive(data.tfe_outputs.vpc.values.private_subnet_ids)
  private_route_table_id = nonsensitive(data.tfe_outputs.vpc.values.private_route_table_id)
  cidr_block             = nonsensitive(data.tfe_outputs.vpc.values.cidr_block)
}


