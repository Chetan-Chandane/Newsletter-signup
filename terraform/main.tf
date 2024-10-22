# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

# Create a route table
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "routetable_assoc" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.routetable.id
}

# Create Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere (adjust for security)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic (port 80)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-0866a3c8686eaeeba"  # ubuntu
  instance_type = "t2.micro"               # instance type
  subnet_id     = aws_subnet.subnet.id
  security_groups = [aws_security_group.ec2_sg.id]
  depends_on = [aws_security_group.ec2_sg]

  # EC2 instance user_data script to install Docker and run the app
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo usermode -aG docker ubuntu
              sudo docker run -d -p 80:3000 chetanchandane/newsletter-signup:latest
              EOF

  tags = {
    Name = "Newsletter-Signup-EC2"
  }

  # Create a public IP address for the EC2 instance
  associate_public_ip_address = true
}

