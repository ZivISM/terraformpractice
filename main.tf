terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"  # change in case you want to work with another AWS account profile
}

resource "aws_instance" "netflix_app" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2_key.key_name

  tags = {
    Name = "netflix-app"
    Env = "dev"
  }
}

# Generate an EC2 key pair and save the private key locally
resource "aws_key_pair" "ec2_key" {
  key_name   = "my-ec2-key"  # Name of the key pair in AWS
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Generate the private key locally using the TLS provider
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save the private key to a local file
resource "local_file" "ec2_private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "./my-ec2-key.pem"
}

  resource "aws_security_group" "netflix_app_sg" {
  name        = "ziv-netflix-app-sg"   
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

