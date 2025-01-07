

provider "aws" {
  region = "us-east-1"  # Ensure the region matches your AWS setup
}

# Security Group for Flask App
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (modify for stricter access)
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic for Flask app
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "FlaskAppSecurityGroup"
  }
}

# EC2 Instance for Flask App
resource "aws_instance" "flask_app" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "devops"                 # Ensure this matches your imported key pair name
  security_groups = [aws_security_group.flask_sg.name]  # Attach security group

  tags = {
    Name = "FlaskAppServer"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.private_key  # Reference the private key from a variable
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
