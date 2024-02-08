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

#  Create Jenkins security group
resource "aws_security_group" "jenkins-sg" {
    name = "Jenkins SG"
    description = "Allow ports 8080 and 22"
    vpc_id = aws_vpc.ovia-prod-vpc.id

    ingress {
        description = "Jenkins"
        from_port = var.jenkins_port
        to_port = var.jenkins_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Jenkins SG"
    } 
}

#  Create SonarQube security group
resource "aws_security_group" "sonarqube-sg" {
    name = "SonarQube SG"
    description = "Allow ports 9000 and 22"
    vpc_id = aws_vpc.ovia-prod-vpc.id

    ingress {
        description = "SonarQube"
        from_port = var.sonarqube_port
        to_port = var.sonarqube_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SonarQube SG"
    } 
}

#  Create Ansible security group
resource "aws_security_group" "ansible-sg" {
    name = "Ansible SG"
    description = "Allow port 22"
    vpc_id = aws_vpc.ovia-prod-vpc.id

    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Ansible SG"
    } 
}

#  Create Grafana security group
resource "aws_security_group" "grafana-sg" {
    name = "Grafana SG"
    description = "Allow ports 3000 and 22"
    vpc_id = aws_vpc.ovia-prod-vpc.id

    ingress {
        description = "Grafana"
        from_port = var.grafana_port
        to_port = var.grafana_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Grafana SG"
    } 
}

#  Create Application security group
resource "aws_security_group" "app-sg" {
    name = "Application SG"
    description = "Allow ports 80 and 22"
    vpc_id = aws_vpc.ovia-prod-vpc.id

    ingress {
        description = "Application"
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Application SG"
    } 
}

#  Create loadBalancer security group
resource "aws_security_group" "lb-sg" {
    name = "loadBalancer SG"
    description = "Allow ports 80"
    vpc_id = aws_vpc.ovia-prod-vpc.id

    ingress {
        description = "loadBalancer"
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "loadBalancer SG"
    } 
}
