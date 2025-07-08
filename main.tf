terraform {
  # This block configures Terraform to store its state file remotely in an S3 bucket.
  # This is a best practice for collaboration and state management.
  backend "s3" {
    bucket = "technova-tfstate-bucket-akash21357"
    key    = "technova/terraform.tfstate"
    region = "ap-south-1"
  }
}

# This block configures the AWS provider, specifying the region where resources will be created.
provider "aws" {
  region = "ap-south-1"
}

# This resource defines the firewall rules (Security Group) for your server.
resource "aws_security_group" "technova_sg" {
  name        = "technova-instance-sg"
  description = "Allow SSH, HTTP, and HTTPS traffic"

  # Allow inbound SSH traffic on port 22 for remote management.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTP traffic on port 80 for the web server.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- THIS IS THE NEW RULE ---
  # Allow inbound HTTPS traffic on port 443 for the Caddy web server's SSL.
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic from the server.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This resource defines the EC2 virtual server itself.
resource "aws_instance" "technova_server" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t2.micro"
  key_name      = "technova-key" # Make sure this matches the name in your AWS Console
  
  # This attaches the security group defined above to the EC2 instance.
  vpc_security_group_ids = [aws_security_group.technova_sg.id]

  # This script runs on the server's first boot to install Docker.
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

# This resource runs a command locally on the GitHub runner AFTER the server is created.
# Its only job is to get the IP address and save it to a file for the next job to use.
resource "null_resource" "save_ip" {
  # This ensures the EC2 instance is fully created before this runs.
  depends_on = [aws_instance.technova_server]

  # This runs on the GitHub runner itself.
  provisioner "local-exec" {
    # This command writes the clean IP address into a file named ip_address.txt
    command = "echo ${aws_instance.technova_server.public_ip} > ip_address.txt"
  }
}
