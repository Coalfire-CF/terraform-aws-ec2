resource "aws_security_group" "this" {
  count = length(var.cidr_security_group_rules) > 0 || length(var.sg_security_group_rules) > 0 ? 1 : 0
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id
}

//resource "aws_security_group_rule" "this" {
//  count = size(var.security_group_rules)
//  from_port = 0
//  protocol = ""
//  security_group_id = ""
//  to_port = 0
//  type = ""
//}

resource "aws_security_group_rule" "this_cidr" {
  count             = length(var.cidr_security_group_rules)
  from_port         = var.cidr_security_group_rules[count.index]["from_port"][0]
  protocol          = var.cidr_security_group_rules[count.index]["protocol"][0]
  security_group_id = aws_security_group.this[0].id
  to_port           = var.cidr_security_group_rules[count.index]["to_port"][0]
  type              = var.cidr_security_group_rules[count.index]["type"][0]
  cidr_blocks       = var.cidr_security_group_rules[count.index]["cidr_blocks"]
  description       = var.cidr_security_group_rules[count.index]["description"][0]
//  lifecycle {
//    create_before_destroy = true
//  }
}

resource "aws_security_group_rule" "this_sg" {
  count                    = length(var.sg_security_group_rules)
  from_port                = var.sg_security_group_rules[count.index]["from_port"][0]
  protocol                 = var.sg_security_group_rules[count.index]["protocol"][0]
  security_group_id        = aws_security_group.this[0].id
  to_port                  = var.sg_security_group_rules[count.index]["to_port"][0]
  type                     = var.sg_security_group_rules[count.index]["type"][0]
  source_security_group_id = var.sg_security_group_rules[count.index]["source_security_group_id"][0]
  description              = var.sg_security_group_rules[count.index]["description"][0]
//  lifecycle {
//    create_before_destroy = true
//  }
}

//resource "aws_security_group_rule" "this_cidr_group" {
//  count = length(var.sg[var.cidr_group_rules["group"]])
//  from_port = var.sg[var.cidr_group_rules["group"]][count.index]["from_port"]
//  protocol = var.sg[var.cidr_group_rules["group"]][count.index]["from_port"]
//  to_port = var.sg[var.cidr_group_rules["group"]][count.index]["to_port"]
//  type = var.sg[var.cidr_group_rules["group"]][count.index]["type"]
//  cidr_blocks = [var.cidr_group_rules["source"]]
//  security_group_id = aws_security_group.this.id
//}


resource "aws_security_group_rule" "egress" {
  count = length(var.cidr_security_group_rules) > 0 || length(var.sg_security_group_rules) > 0 ? 1 : 0
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this[0].id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}