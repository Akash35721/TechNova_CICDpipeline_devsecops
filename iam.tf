# Creates an IAM role for the EC2 instance
resource "aws_iam_role" "technova_ec2_role" {
  name = "TechNova-EC2-CloudWatch-Role"

  # The policy that allows EC2 to assume this role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attaches the AWS-managed policy for CloudWatch Agent to the role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attach" {
  role       = aws_iam_role.technova_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Creates an instance profile that can be associated with the EC2 instance
resource "aws_iam_instance_profile" "technova_instance_profile" {
  name = "TechNova-EC2-Instance-Profile"
  role = aws_iam_role.technova_ec2_role.name
}