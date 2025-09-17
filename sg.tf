module "security_group" {
  source = "git::https://github.com/Coalfire-CF/terraform-aws-securitygroup?ref=v1.0.2"
  count  = var.create_security_group ? 1 : 0

  name        = "${var.name}-sg"
  description = var.sg_description
  vpc_id      = var.vpc_id

  ingress_rules = length(var.ingress_rules) == 0 ? {} : var.ingress_rules
  egress_rules  = length(var.egress_rules) == 0 ? {} : var.egress_rules

  network_interface_resource_associations = var.additional_eni_ids
}

# Attach additional security groups to any additional network interfaces
resource "aws_network_interface_sg_attachment" "additional" {
  count = length(local.additional_sg_to_additional_eni)

  security_group_id    = local.additional_sg_to_additional_eni[count.index][0]
  network_interface_id = local.additional_sg_to_additional_eni[count.index][1]
}
