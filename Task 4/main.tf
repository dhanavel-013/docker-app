provider "aws" {
  region = "us-east-1"
}

# Generate SSH key (optional – or use your own key)
resource "aws_key_pair" "xops_key" {
  key_name   = "terraform_dv1"
  public_key = file("~/.ssh/terraform-dv.pub")   # adjust if your key file differs
}

# Security group to allow SSH + HTTP
resource "aws_security_group" "xops_sg" {
  name        = "xops-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "xops_ec2" {
  ami                    = "ami-00ca32bbc84273381"   # Amazon Linux 2 in us-east-1
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  key_name               = aws_key_pair.xops_key.key_name
  vpc_security_group_ids = [aws_security_group.xops_sg.id]   # ✅ fixed

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3 git nginx
              systemctl enable nginx
              systemctl start nginx
              echo "Hello from XOps Microchallenge 4!" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "xops-microchallenge4"
  }
}



output "ec2_public_ip" {
  value = aws_instance.xops_ec2.public_ip
}
