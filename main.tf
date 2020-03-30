module "label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace = var.namespace
  stage     = var.stage
  name      = var.name
}

module "role_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = ["role"]
}

#####################
## SSM AGENT ROLE ##
###################

data "aws_iam_policy_document" "default" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  name                 = module.role_label.id
  assume_role_policy   = data.aws_iam_policy_document.default.json
  permissions_boundary = var.permissions_boundary
  tags                 = module.role_label.tags
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = var.ssm_policy_arn
}

resource "aws_iam_instance_profile" "default" {
  name = module.role_label.id
  role = aws_iam_role.default.name
}

#####################
## SECURITY GROUP ##
###################

resource "aws_security_group" "default" {
  vpc_id      = var.vpc_id
  name        = module.label.id
  description = "Allow ALL egress from SSM Agent."
  tags        = module.label.tags
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

###################
## ECS INSTANCE ##
#################

resource "aws_instance" "default" {
  instance_type          = var.instance_type
  ami                    = var.ami != "" ? var.ami : data.aws_ami.amazon_linux_2.id
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.default.name
  vpc_security_group_ids = [aws_security_group.default.id]
  tags                   = module.label.tags
  user_data              = var.user_data
}
