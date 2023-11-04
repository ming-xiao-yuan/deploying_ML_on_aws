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
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}

resource "aws_security_group" "security_group" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_vpc" "default" {
  default = true
}

resource "aws_key_pair" "key_pair_name_orchestrator" {
  key_name   = var.key_pair_name_orchestrator
  public_key = file("my_terraform_key.pub")
}

resource "aws_key_pair" "key_pair_name_workers" {
  key_name   = var.key_pair_name_workers
  public_key = file("my_terraform_key.pub")
}

resource "aws_instance" "orchestrator" {
  ami                    = "ami-03a6eaae9938c858c"
  instance_type          = "m4.large"
  key_name               = aws_key_pair.key_pair_name_orchestrator.key_name
  vpc_security_group_ids = [aws_security_group.security_group.id]
  availability_zone      = "us-east-1d"
  user_data              = file("./orchestrator_user_data.sh")
  tags = {
    Name = "Orchestrator"
  }
}

resource "aws_instance" "workers" {
  ami                    = "ami-03a6eaae9938c858c"
  instance_type          = "m4.large"
  key_name               = aws_key_pair.key_pair_name_workers.key_name
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
