#Provider block (init every time it changes)
provider "aws" {
    profile = "default"
    region = "eu-north-1"
}

#Keypair
resource "aws_key_pair" "my_key" {
       key_name        = "windows_keypair"
       public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYDXWE0gtIY6q9E/+dWCLgnnjhBw7KdOI3Dv8z8J3bX1NWaTjq/Nf+32y2RNsmpKbl5dgRIHa7iFU8Nz1jiIY3TpzEWFMxitbIvQMBd/spyRvWtY98omE0k83M4W7a2P4jHnA5t7ZUeVs7PcsH4b6/M/B2vIhpZ2FNkdLeG/Q3c4XgenOGfu4mlLGeiFr3ekRKZv/qigvxINnj7HeBumo424zWhVfgFyDsuKpoioZ3mxMboTXN9ZWqbTcu0wJ0GXCRyKdLC/Vr3XRdjHrdfVXk+K4Tc1llLOvNi4Sri8RVf2/yv/HYtjkA7NA5iMzgDdOiTG86DncKUYF+alLapchD"       

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
  description = "launch-wizard-1 created 2025-04-14T15:41:12.321Z"  #change to some like allow TCP only through our IPs
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
                "46.103.91.241/32",
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


