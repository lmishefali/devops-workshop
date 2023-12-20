provider "aws"{
    region ="ap-south-1"
}

resource "aws_instance" "demo-server" {
  ami ="ami-0a5ac53f63249fba0"
  instance_type = "t2.micro"
  key_name ="terraformkey"
  security_groups = ["demo-sg" ]
}

resource "aws_security_group" "allow_ssh" {
  name        = "demo-sg"
  description = "Allow TLS inbound traffic"
 
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_ssh"
  }
} 