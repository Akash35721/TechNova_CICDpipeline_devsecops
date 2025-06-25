# --- main.tf (FINAL CODE) ---

provider "aws" {
  region = "ap-south-1" 
}

# Creates a firewall (Security Group) for our server
resource "aws_security_group" "technova_sg" {
  name        = "technova-instance-sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22    # Allows SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80    # Allows HTTP (web traffic)
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

# Creates the EC2 Server
resource "aws_instance" "technova_server" {
  ami           = "ami-0f5ee92e2d63afc18" # Ubuntu 22.04 in ap-south-1
  instance_type = "t2.micro"             # Free-tier eligible size

  # This tells AWS to install the public key matching the NAME you created in Step 1.
  # This is NOT a secret. It is just the name.
  key_name      = "technova-key" # <-- This MUST match the name from the AWS console

  vpc_security_group_ids = [aws_security_group.technova_sg.id]

  # This script runs once on boot to install Docker.
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "TechNova-Server-Terraform"
  }
}

# This makes the server's IP address available to other jobs.
output "instance_public_ip" {
  value = aws_instance.technova_server.public_ip
}