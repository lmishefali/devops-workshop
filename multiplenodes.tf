provider "aws"{
    region ="ap-south-1"
}

resource "aws_instance" "vpc-subnet" {
  ami ="ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name ="terraform"
 //whenevrer we giv vpc subnet we dont reqiured --> security_groups = ["demo-sg" ]
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id = aws_subnet.dpw-public_subnet_01.id
  
//for multiple instance we used "for_each argument"
for_each = toset(["jenkins-master", "build-slave" , "ansible"])
   tags = { 
     Name = "${each.key}"
   }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.dpw-vpc.id
 
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  
  ingress {
    description      = "Jenkins port"
    from_port        = 8080
    to_port          = 8080
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

 //Create a vpc
 resource "aws_vpc" "dpw-vpc" {
       cidr_block = "10.1.0.0/16"
       tags = {
        Name = "dpw-vpc"
     }
   }

   //Create a Subnet-1 
resource "aws_subnet" "dpw-public_subnet_01" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1a"
    tags = {
      Name = "dpw-public_subnet_01"
    }
}

//Create a Subnet-2 
resource "aws_subnet" "dpw-public_subnet_02" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1b"
    tags = {
      Name = "dpw-public_subnet_01"
    }
}

// internet gateway
resource "aws_internet_gateway" "dpw-igw" {
  vpc_id = aws_vpc.dpw-vpc.id
tags = {
  Name ="dpw.igw"
}

}

// Create a route table 
resource "aws_route_table" "dpw-public-rt" {
    vpc_id = aws_vpc.dpw-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpw-igw.id
    }
    tags = {
      Name = "dpw-public-rt"
    }
}

// Associate subnet with route table

resource "aws_route_table_association" "dpw-rta-public-subnet-1" {
    subnet_id = aws_subnet.dpw-public_subnet_01.id
    route_table_id = aws_route_table.dpw-public-rt.id
}
