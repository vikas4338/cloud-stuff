# #data
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# terraform {
#   backend "s3" {
#     bucket = "iac-terraform-aws-projects"
#     dynamodb_table = "state.lock"
#     key    = "aws-terraform-projects/dev/aws-highly-available-application/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

# resource "aws_vpc" "app" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_hostnames = true

#   tags = {
#     environment = "dev"
#   }
# }

# resource "aws_internet_gateway" "app" {
#   vpc_id = aws_vpc.app.id
# }

# resource "aws_subnet" "public_subnet1" {
#   cidr_block = var.vpc_public_subnets_cidr_block[0]
#   vpc_id = aws_vpc.app.id
#   map_public_ip_on_launch = true
#   availability_zone = data.aws_availability_zones.available.names[0]
# }

# resource "aws_subnet" "public_subnet2" {
#   cidr_block = var.vpc_public_subnets_cidr_block[1]
#   vpc_id = aws_vpc.app.id
#   map_public_ip_on_launch = true
#   availability_zone = data.aws_availability_zones.available.names[1]
# }

# resource "aws_route_table" "app_internet_access" {
#   vpc_id = aws_vpc.app.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.app.id
#   }
# }

# resource "aws_route_table_association" "rt_association_with_subnet1" {
#   subnet_id = aws_subnet.public_subnet1.id
#   route_table_id = aws_route_table.app_internet_access.id
# }

# resource "aws_route_table_association" "rt_association_with_subnet2" {
#   subnet_id = aws_subnet.public_subnet2.id
#   route_table_id = aws_route_table.app_internet_access.id
# }

# resource "aws_security_group" "ec2_sg" {
#   vpc_id = aws_vpc.app.id

#   ingress {
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = [var.vpc_cidr_block]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "alb_sg" {
#   name = "nginx alb sg"
#   vpc_id = aws_vpc.app.id

#   ingress {
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }