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

##### SECURITY GROUPS #####
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http_s" {
  name        = "allow_http_s"
  description = "Allow HTTP/S inbound traffic"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_s"
  }
}

resource "aws_security_group" "monitoring" {
  name        = "monitoring"
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

resource "aws_security_group" "mlflow" {
  name        = "mlflow"
  description = "Allow HTTP access for mlflow"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
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
##### SECURITY GROUPS END #####

##### EC2 INSTANCE PROVISION #####
resource "aws_instance" "infra_devops" {
  ami           = data.aws_ami.ubuntu.id
  key_name      = "myKey"
  instance_type = "t2.micro"

  security_groups = [aws_security_group.monitoring.name, aws_security_group.allow_ssh.name, aws_security_group.allow_http_s.name, aws_security_group.mlflow.name]

  tags = {
    Name = "infra_devops"
  }

}
##### EC2 INSTANCE PROVISION END #####

##### OUTPUT SECTION #####
output "instance_public_ip_infra_devops" {
  value = aws_instance.infra_devops.public_ip
}

output "instance_private_ip_infra_devops" {
  value = aws_instance.infra_devops.private_ip
}

# Output the AMI ID used
output "ami_id" {
  value = data.aws_ami.ubuntu.id
}
##### OUTPUT SECTION END #####