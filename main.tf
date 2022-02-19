terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "vpc-hello-world" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "vpc-hello-world"
  }
}

resource "aws_security_group" "sc-hello-world" {
  name = "name-sc-hello-world"
  description = "description-sc-hello-world"
  vpc_id = aws_vpc.vpc-hello-world.id

  ingress {
    from_port = 0
    protocol  = "tcp"
    to_port   = 0
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
  }
}

resource "aws_internet_gateway" "igw-hello-world" {
  vpc_id = aws_vpc.vpc-hello-world.id
  tags = {
    Name = "igw-hello-world"
  }
}

resource "aws_subnet" "subnet-hello-world-A" {
  vpc_id = aws_vpc.vpc-hello-world.id
  cidr_block = "10.0.11.0/24"

  tags = {
    Name = "subnet-hello-world-a"
  }

  availability_zone = "eu-west-3a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet-hello-world-B" {
  vpc_id = aws_vpc.vpc-hello-world.id
  cidr_block = "10.0.12.0/24"

  tags = {
    Name = "subnet-hello-world-b"
  }

  availability_zone = "eu-west-3b"
  map_public_ip_on_launch = true
}