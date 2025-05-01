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

