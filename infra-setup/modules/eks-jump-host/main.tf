locals {

  application_tag = lookup(var.merged_tags, "application")
  environment_tag = lookup(var.merged_tags, "environment")
  cost_center_tag = lookup(var.merged_tags, "cost_center")

  common_prefix = "${local.application_tag}-${local.environment_tag}"

}


data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

output "ami_id" {
  value = data.aws_ami.al2.id
}
resource "aws_instance" "jump_server" {
  ami                         = data.aws_ami.al2.id
  instance_type               = "t2.medium"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name


  tags = merge(var.merged_tags, {
    "Name" = "${local.common_prefix}-jump"
  })
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.merged_tags, {
    "Name" = "${local.common_prefix}-jump-sg"
  })
}


resource "aws_iam_role" "ec2_ssm_role" {
  name = "${local.common_prefix}-jump-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })


}

resource "aws_iam_role_policy_attachment" "ssm_core_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 🔗 Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${local.common_prefix}-jump-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_iam_policy" "eks_access_policy" {
  name        = "EKSAccessPolicy"
  description = "Policy to allow describe cluster and access Kubernetes API"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_access_policy_attachment" {
  policy_arn = aws_iam_policy.eks_access_policy.arn
  role       = aws_iam_role.ec2_ssm_role.name
}
