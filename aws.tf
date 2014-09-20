variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}
variable "aws_region" {}
variable "cidr_office" {}
variable "cidr_github" {}
variable "cidr" {
    default = "192.168.11.0/24"
}
variable "amis_ci_master" {
    # Ubuntu Server 14.04 LTS (HVM), SSD Volume Type
    default = {
        ap-southeast-1 = "ami-12356d40"
    }
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_vpc" "my-vpc" {
    cidr_block = "${var.cidr}"
    enable_dns_support = true
    enable_dns_hostnames = true
}

output "vpc_id" {
    value = "${aws_vpc.my-vpc.id}"
}

resource "aws_subnet" "main" {
    vpc_id = "${aws_vpc.my-vpc.id}"
    cidr_block = "${var.cidr}"
    availability_zone = "${var.aws_region}b"
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.my-vpc.id}"
}

resource "aws_route_table" "igw" {
    vpc_id = "${aws_vpc.my-vpc.id}"
    route {
        gateway_id = "${aws_internet_gateway.gw.id}"
        cidr_block = "0.0.0.0/0"
    }
}

resource "aws_route_table_association" "main_and_igw" {
    subnet_id = "${aws_subnet.main.id}"
    route_table_id = "${aws_route_table.igw.id}"
}

resource "aws_security_group" "allow_all" {
    vpc_id = "${aws_vpc.my-vpc.id}"
    name = "allow_all"
    description = "Allow all inbound traffic"
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["${var.cidr_office}", "${var.cidr_github}"]
    }
}

resource "aws_instance" "ci-master" {
    ami = "${lookup(var.amis_ci_master, var.aws_region)}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.main.id}"
    key_name = "${var.key_name}"
    security_groups = ["${aws_security_group.allow_all.id}"]
    count = 1
}

resource "aws_eip" "ci-master" {
    instance = "${aws_instance.ci-master.id}"
    vpc = true
}

output "public_ip.ci-master" {
    value = "${aws_instance.ci-master.public_ip}"
}
