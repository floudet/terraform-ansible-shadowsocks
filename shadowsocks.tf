variable "aws_region" {
  type = string
}

variable "aws_key_name" {
  type = string
}

variable "aws_public_key" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "private_key_file" {
  type = string
}

variable "shadowsocks_pwd" {
  type = string
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

resource "aws_key_pair" "default_key_pair" {
  key_name   = var.aws_key_name
  public_key = var.aws_public_key
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "asg_shadowsocks" {
  name        = "sg_shadowsocks"
  description = "security group for Shadowsocks server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8
    to_port   = 0
    protocol  = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform : "true"
  }
}

data "aws_ami" "ubuntu_bionic" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "shadowsocks_server" {
  ami           = data.aws_ami.ubuntu_bionic.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.default_key_pair.key_name

  vpc_security_group_ids = [
    aws_security_group.asg_shadowsocks.id
  ]

  root_block_device {
      volume_type = "gp2"
      volume_size = 8
  }

  volume_tags   = {
    Name      : var.instance_name
    Terraform : "true"
  }

  provisioner "remote-exec" {
    inline = ["touch /tmp/terraform_was_here"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_file)
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.private_key_file} --extra-vars 'shadowsockspwd=${var.shadowsocks_pwd} hostname=${var.instance_name}' shadowsocks.yml"
  }

  tags = {
    Name      : var.instance_name
    Terraform : "true"
  }
}
