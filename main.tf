# --- main.tf (Final Version with File Output) ---

provider "aws" {
  region = "ap-south-1" 
}

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

resource "aws_instance" "technova_server" {
  ami           = "ami-0f5ee92e2d63afc18" 
  instance_type = "t2.micro"             
  key_name      = "technova-key" # Make sure this matches the name in your AWS Console
  vpc_security_group_ids = [aws_security_group.technova_sg.id]

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

# --- THIS IS THE NEW PART ---
# This resource runs a command locally AFTER the technova_server is created.
resource "null_resource" "save_ip" {
  # This makes sure the EC2 instance is created first.
  depends_on = [aws_instance.technova_server]

  # This runs on the GitHub runner itself.
  provisioner "local-exec" {
    # This command writes the IP address into a file named ip_address.txt
    command = "echo ${aws_instance.technova_server.public_ip} > ip_address.txt"
  }
}