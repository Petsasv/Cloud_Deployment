variable "ssh_allowed_ips" {
  type    = list(string)
  default = [
    "62.74.39.191/32",
    "45.139.214.56/32",
    "141.237.236.10/32"
  ]
  description = "List of IPs allowed to SSH into EC2"
}

variable "windows_ip"{
    default = ["51.20.7.35/32"]   # public ip 

    description = "Windows IP allowed to HTTP into website"
}