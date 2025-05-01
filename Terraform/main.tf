#Provider block (init every time it changes)
provider "aws" {
    profile = "default"
    region = "eu-north-1"
}

#Resource Blocks
#WINDOWS EC2
resource "aws_instance" "Windows" {
  ami = "ami-0d188df7cedce7d90"
  instance_type = "t3.micro"
  subnet_id  = "subnet-0523303f286361516"
  vpc_security_group_ids = ["sg-05fcf6e902f1c54c8",]
  key_name = "windows_keypair"
  associate_public_ip_address = false

  tags = {
        "Name" = "Windows"
    }
}

#LINUX EC2
resource "aws_instance" "Linux" {
  ami = "ami-08f78cb3cc8a4578e"
  instance_type = "t3.micro"
  subnet_id  = "subnet-0523303f286361516"
  vpc_security_group_ids = ["sg-0e76b679bb2ce9ad1",]
  key_name = "windows_keypair"
  associate_public_ip_address = false

  tags = {
        "Name" = "Linux"
    }
}

#Security Groups
resource "aws_security_group" "sec_wind" {
  name = "launch-wizard-1"
  description = "Security Group allows only IPs of group members"  #launch-wizard-1 created 2025-04-14T15:41:12.321Z
  vpc_id      = "vpc-0490e9d4b8b258fde" 

  ingress     = [
        {
            cidr_blocks      = [
                "79.103.153.5/32",
            ]
            description      = "Pepe IP"
            from_port        = 3389
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 3389
        },
        {
            cidr_blocks      = [
                "79.107.174.132/32",
                "45.139.214.155/32",
            ]
            description      = null
            from_port        = 3389
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 3389
        },
    ]

    egress      = [
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = null
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = false
            to_port          = 0
        },
    ]
}


resource "aws_security_group" "linux_sec" {
    name        = "launch-wizard-2"
    description = "launch-wizard-2 created 2025-04-22T13:42:16.572Z"
    vpc_id      = "vpc-0490e9d4b8b258fde"

    egress      = [
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = null
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = false
            to_port          = 0
        },
    ]
    ingress     = [
        {
            cidr_blocks      = [
                "172.31.40.127/32",
            ]
            description      = null
            from_port        = 80
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 80
        },
        {
            cidr_blocks      = [
                "79.103.153.5/32",
                "79.107.174.132/32",
                "45.139.214.155/32",
            ]
            description      = null
            from_port        = 22
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 22
        },
    ]  
}


