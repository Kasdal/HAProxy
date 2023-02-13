terraform {
  required_version = ">= 0.13"
  required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 3.0"
   }
 }
}

variable ssh_key {
  type = string
  default = "/home/kas/.ssh/id.rsa"
}


provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "Terransible" {
  key_name   = "Terransible2"
  public_key = file("~/.ssh/id_rsa.pub")
  
}

resource "aws_security_group" "haproxy_sg" {
  name        = "haproxy_security_group"
  description = "Allow incoming HTTP and Node.js traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9002
    to_port     = 9002
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


resource "aws_instance" "myec2" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.Terransible.key_name
  associate_public_ip_address = true
    security_groups = [
    aws_security_group.haproxy_sg.name
  ]

  provisioner "local-exec" {
    command = "sleep 150"
    
  }
}

resource "null_resource" "ansible" {
provisioner "local-exec" {

  working_dir = "/home/kasdal/Ansible"
  command = "ansible-playbook -i ${aws_instance.myec2.public_ip}, playbook.yml"
}
  
}
