# terraform/main.tf
provider "aws" {
  region = "eu-west-3"
}

# Data source to get the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["*ubuntu-*24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Allow HTTP access for Prometheus and Grafana"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
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

resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.ubuntu.id
  key_name      = "myKey"
  instance_type = "t2.micro"

  security_groups = [aws_security_group.monitoring_sg.name]

  tags = {
    Name = "Prometheus-Grafana"
  }

}

# Output the public IP of the EC2 instance
output "instance_public_ip_monitoring" {
  value = aws_instance.monitoring.public_ip
}

output "instance_private_ip_monitoring" {
  value = aws_instance.monitoring.private_ip
}

# Output the AMI ID used
output "ami_id" {
  value = data.aws_ami.ubuntu.id
}