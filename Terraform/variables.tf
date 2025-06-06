variable "ssh_allowed_ips" {
  type    = list(string)
  default = [
    "79.103.26.106/32",
    "142.237.236.10/32",
    "79.166.156.20/32",
    "13.60.243.160/32"
  ]
  description = "List of IPs allowed to SSH into EC2"
}

variable "windows_ip"{
    default = ["51.20.7.35/32"]   # public ip 

    description = "Windows IP allowed to HTTP into website"
}