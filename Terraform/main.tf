
terraform{
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "6.0.0-beta1"
      }
    }

    backend "s3" {
      bucket = "state28246tera82920bucket28109"
      dynamodb_table = "state-lock"
      key = "global/mystatefile/terraform.tfstate" #file path to terrastate
      region = "eu-north-1"
      encrypt = true
    }
}

provider "aws" {
    #profile = "default"
    region = "eu-north-1"
}

#EC2
resource "aws_key_pair" "main_key" {
  key_name   = "access_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDM0a08XcI6zKbE/gqHbCHdTVErkMHjLkwb9zvcbaJjGl1qjpm1yP7P+Tq4Vpgk6duvNRd+qd5weEegf4BpqdfTtlKHkPIUlPilO7EBmXkFokADvixqxUGwMcn9NVh9cXfmUzh14A+1C7Zuw7RZFSEN6o/tVLPo8n5MhJpeJxJuV9ZHUMkYlx2VuK57vL2XhgNpz+2cJvmQBEIRlBG4V9EGZ0V2sCgJLKMOM0ZqBahaE2S3rwUkGO2eCUaxhHZ548wEQkzICFC3GNxC9cPYTWAHsk1VnKUvoKFI7J1Gxt8fKAxd3RoXfhUE7NYKwg4yh++6/cXUiVINKjYL+9Z5stWZ"

lifecycle {
    prevent_destroy = false #true
  }
}



resource "aws_instance" "Windows_Gateway" {
  ami = "ami-0d188df7cedce7d90"
  instance_type = "t3.micro"
  subnet_id  = "subnet-0523303f286361516"
  key_name = "access_key"
  vpc_security_group_ids = [aws_security_group.windows_sec.id]

  tags = {
        "Name" = "Windows Server to act as gateway"
    }
}

resource "aws_instance" "Linux_Host" {
  ami = "ami-08f78cb3cc8a4578e"
  instance_type = "t3.micro"
  subnet_id  = "subnet-0523303f286361516"
  key_name = "access_key" 
  vpc_security_group_ids = [aws_security_group.linux_sec.id]

  tags = {
        "Name" = "Linux server that hosts website"
    }
}

resource "aws_security_group" "windows_sec" {
  name = "windows-security"
  description = "Allow RDP traffic"  


  ingress  {    
            cidr_blocks      = [
                "79.103.26.106/32",
                "45.139.214.104/32",
                "141.255.126.50/32",
            ]
            from_port   = 3389
            to_port     = 3389
            protocol    = "tcp"
            description      = "Users Ips"
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            security_groups  = []
            self             = false
        }
    

      egress {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "linux_sec" {
    name        = "linux-security"
    description = "Allow HTTP (from windows machine only) and SSH traffic (from our IP only)"

      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }

    ingress     = [
        {
            cidr_blocks      = [
                "172.31.40.127/32",  #Windows IP
            ]
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            description      = "Windows VM IP"
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            security_groups  = []
            self             = false
        },
        {
            cidr_blocks      = [    
                "79.103.26.106/32",
                "45.139.214.104/32",
                "141.255.126.50/32",
            ]
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            description      = "Users IPs"
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            security_groups  = []
            self             = false
        }
    ]  
}
