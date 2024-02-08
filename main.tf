# Initiate the provider
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create the VPC
resource "aws_vpc" "ovia-prod-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Production VPC"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "ovia-IGW" {
    vpc_id = aws_vpc.ovia-prod-vpc.id 
}

# Create an Elastic IP to associate with NAT Gateway
resource "aws_eip" "ovia-nat-eip" {
    depends_on = [ aws_internet_gateway.ovia-IGW ]
}

# Create the NAT Gateway
resource "aws_nat_gateway" "ovia-nat-gw" {
    allocation_id = aws_eip.ovia-nat-eip.id
    subnet_id = aws_subnet.ovia-public_subnet1.id
    tags = {
        Name = "NAT Gateway"
    }
}

# Create the public route table
resource "aws_route_table" "ovia-public-rt" {
    vpc_id = aws_vpc.ovia-prod-vpc.id
    route {
        cidr_block = var.all_cidr
        gateway_id = aws_internet_gateway.ovia-IGW.id
    }
    tags = {
        Name = "Public RT"  
    }
}

# Create the private route table
resource "aws_route_table" "ovia-private-rt" {
    vpc_id = aws_vpc.ovia-prod-vpc.id
    route {
        cidr_block = var.all_cidr
        nat_gateway_id = aws_nat_gateway.ovia-nat-gw.id
    }
    tags = {
        Name = "Private RT"  
    }
}

# Create the public subnet1
resource "aws_subnet" "ovia-public_subnet1" {
    vpc_id = aws_vpc.ovia-prod-vpc.id
    cidr_block = var.public_subnet1_cidr
    availability_zone = var.availabilty_zone
    map_public_ip_on_launch = true
    tags = {
        Name = "Public subnet 1"
    }
}

# Create the public subnet2
resource "aws_subnet" "ovia-public_subnet2" {
    vpc_id = aws_vpc.ovia-prod-vpc.id
    cidr_block = var.public_subnet2_cidr
    availability_zone = "us-east-2b"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public subnet 2"
    }
}

# Create the private subnet1
resource "aws_subnet" "ovia-private_subnet" {
    vpc_id = aws_vpc.ovia-prod-vpc.id
    cidr_block = var.private_subnet_cidr
    availability_zone = "us-east-2a"
    tags = {
        Name = "Private subnet"
    }
}

# Associate public RT with public subnet1
resource "aws_route_table_association" "public_subnet1_rt_association" {
    subnet_id = aws_subnet.ovia-public_subnet1.id
    route_table_id = aws_route_table.ovia-public-rt.id
}

# Associate public RT with public subnet2
resource "aws_route_table_association" "public_subnet2_rt_association" {
    subnet_id = aws_subnet.ovia-public_subnet2.id
    route_table_id = aws_route_table.ovia-public-rt.id
}

# Associate private RT with private subnet
resource "aws_route_table_association" "private_subnet_rt_association" {
    subnet_id = aws_subnet.ovia-private_subnet.id
    route_table_id = aws_route_table.ovia-private-rt.id
}