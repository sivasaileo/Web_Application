provider "aws" {
  region = "us-east-1"
}

# Security Group for Flask App
resource "aws_security_group" "flask_sg_1" {
  name        = "flask-app-sg_1"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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
    Name = "FlaskAppSecurityGroup1"
  }
}

# Generate a new SSH key pair
resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create a new key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.deployer.public_key_openssh
}

# EC2 Instance for Flask App
resource "aws_instance" "flask_app" {
  ami           = "ami-0c02fb55956c7d316"  
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name               
  security_groups = [aws_security_group.flask_sg_1.name]  

  tags = {
    Name = "FlaskAppServer"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.deployer.private_key_pem
      host        = self.public_ip
    }

    inline = [
      "sudo yum update -y",
      "sudo yum install python3 git -y",
      "sudo pip3 install flask",
      "git clone https://github.com/sivasaileo/Web_Application.git",
      "cd Web_Application && nohup python3 app.py &"
    ]
  }
}

output "private_key_pem" {
  value     = tls_private_key.deployer.private_key_pem
  sensitive = true
}