variable "ssh_allowed_ips" {
  type    = list(string)
  default = [
    "79.103.26.106/32",
    "45.139.214.104/32",
    "141.255.126.50/32"
  ]
  description = "List of IPs allowed to SSH into EC2"
}

variable "windows_ip"{
    default = ["172.31.40.127/32"]

    description = "Windows IP allowed to HTTP into website"
}