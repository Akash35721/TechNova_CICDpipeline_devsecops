
terraform {

  backend "s3" {
    bucket = "technova-tfstate-bucket-akash21357" 
    key    = "technova/terraform.tfstate"     
    region = "ap-south-1"                    
  }
}

provider "aws" {
  region = "ap-south-1" 
}

# This resource defines the firewall rules for your server.
resource "aws_security_group" "technova_sg" {
  name        = "technova-instance-sg"
  description = "Allow HTTP and SSH traffic"

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

# This resource defines the EC2 virtual server itself.
resource "aws_instance" "technova_server" {
  ami           = "ami-0f918f7e67a3323f0" 
  instance_type = "t2.micro"             
  key_name      = "technova-key" # Make sure this matches the name in your AWS Console
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