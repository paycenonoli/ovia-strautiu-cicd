# Define variables

variable "region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "all_cidr" {
  type = string
}

variable "public_subnet1_cidr" {
  type = string
}

variable "public_subnet2_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "availabilty_zone" {
  type = string
}

variable "jenkins_port" {
  type = number
}

variable "sonarqube_port" {
  type = number
}

variable "grafana_port" {
  type = number
}

variable "http_port" {
  type = number
}

variable "ssh_port" {
  type = number
}
