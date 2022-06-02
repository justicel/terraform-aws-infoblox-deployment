locals {
  create_iam = var.create_iam ? 1 : 0
}

resource "aws_iam_role" "vdiscovery" {
  count              = local.create_iam
  name               = "${var.name_prefix}_NIOS-vDiscovery-Role"
  assume_role_policy = file("${path.module}/files/nios-assume-role.json")
  tags               = var.custom_tags
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_iam
  statement {
    actions = [
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "iam:GetUser"
    ]
    resources = ["arn:aws:iam::*:user/*"]
  }
}

resource "aws_iam_policy" "assume_role" {
  count       = local.create_iam
  name        = "${var.name_prefix}_NIOS-vDiscovery-Policy"
  description = "vNIOS appliance discovery policy for describing VPC information"
  policy      = data.aws_iam_policy_document.assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "assume_role_attachment" {
  count      = local.create_iam
  role       = aws_iam_role.vdiscovery[0].name
  policy_arn = aws_iam_policy.assume_role[0].arn
}
