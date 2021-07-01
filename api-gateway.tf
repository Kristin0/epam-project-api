
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "epam-project-tfstate"
    key = "epam/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_availability_zones" "zones" {}
data "aws_ami" "ubuntu" {
  most_recent  = true 
  owners = [ "099720109477" ]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "allow_4200_8080_22" {
  vpc_id = aws_vpc.epam-project.id
  
  dynamic "ingress" {
    for_each = ["4200", "8080", "22"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_instance" "web-api" {
  subnet_id = aws_subnet.public.*.id[0]
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_4200_8080_22.id]
  tags = {
    Name = "web-api"
  }
  key_name = "A4L"
}

resource "local_file" "application" {
 content = templatefile("application.tmpl",
 {
     host_ip = aws_instance.web-api.public_ip 
 }
 )
 filename = "/home/Kris/Desktop/Books/coding/Linux/materials/devops/test/api-gateway/application.yml"
 
}