# Configure the AWS provider and specify the region
provider "aws" {
  region = "ap-south-1" # The region your instance is in
}

# 1. Create a Security Group to allow HTTP and SSH traffic
resource "aws_security_group" "technova_sg" {
  name        = "technova-instance-sg"
  description = "Allow HTTP and SSH inbound traffic"

  # Rule to allow inbound SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule to allow inbound HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "technova-sg"
  }
}

# 2. Create the EC2 Instance
resource "aws_instance" "technova_server" {
  ami           = "ami-0f5ee92e2d63afc18" # AMI for Ubuntu 22.04 in ap-south-1 (Mumbai). Verify this is current.
  instance_type = "t2.micro"             # As planned in your project scope 

  # Attach the security group we created above
  vpc_security_group_ids = [aws_security_group.technova_sg.id]

  # This is where you automate the Docker installation!
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "TechNova-Server-Terraform"
  }
}

# 3. Output the Public IP Address of the instance
output "instance_public_ip" {
  value = aws_instance.technova_server.public_ip
}