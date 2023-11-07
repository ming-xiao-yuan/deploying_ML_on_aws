terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.19.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_ACCESS_KEY
  token      = var.AWS_SESSION_TOKEN
}

resource "aws_security_group" "security_group" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


data "aws_vpc" "default" {
  default = true
}

resource "aws_key_pair" "key_pair_name" {
  key_name   = var.key_pair_name
  public_key = file("my_terraform_key.pub")
}

/*
This example creates an IAM role named "orchestrator_iam_role" that 
allows EC2 instances to assume it.
*/
resource "aws_iam_role" "orchestrator_iam_role" {
  name = "orchestrator_iam_role"
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

/*
In this updated policy, the ec2:DescribeInstances 
action is allowed for all resources (*). It is possible to 
customize the resource specification to be more restrictive if needed.
*/
resource "aws_iam_policy" "orchestrator_iam_policy"{
  name                   = "orchestrator_iam_policy"
  description            = "Allows the orchestrator to fetch the informations of all the EC2 instances"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeInstances"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "orchestrator_ec2_iam_policy_attachement"{
  name       = "orchestrator_ec2_iam_policy_attachement"
  policy_arn = aws_iam_policy.orchestrator_iam_policy.arn
  roles      = [aws_iam_role.orchestrator_iam_role.name]
}

/*
This creates an instance profile named ""orchestrator_instance_profile" 
and associates it with the "orchestrator_iam_role"*/
resource "aws_iam_instance_profile" "orchestrator_instance_profile"{
  name = "orchestrator_instance_profile"
  role = aws_iam_role.orchestrator_iam_role.name
}


resource "aws_instance" "orchestrator" {
  ami                    = "ami-03a6eaae9938c858c"
  instance_type          = "m4.large"
  key_name               = aws_key_pair.key_pair_name.key_name
  vpc_security_group_ids = [aws_security_group.security_group.id]
  availability_zone      = "us-east-1d"
  user_data              = file("./orchestrator_user_data.sh")
  iam_instance_profile   = aws_iam_instance_profile.orchestrator_instance_profile.name
  tags = {
    Name = "Orchestrator"
  }
}

resource "aws_instance" "workers" {
  ami           = "ami-03a6eaae9938c858c"
  instance_type = "m4.large"
  root_block_device {
    volume_type = "gp2"
    volume_size = 100
  }
  key_name               = aws_key_pair.key_pair_name.key_name
  vpc_security_group_ids = [aws_security_group.security_group.id]
  availability_zone      = "us-east-1d"
  user_data              = file("./worker_user_data.sh")
  count                  = 4
  tags = {
    Name = "Worker-${count.index}"
  }
}

output "orchestrator_url" {
  description = "The infrastructure orchestrator url"
  value       = aws_instance.orchestrator.public_dns
}
