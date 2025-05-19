variable "ssh_allowed_ips" {
  type    = list(string)
  default = [
    "79.103.26.106/32",
    "45.139.214.56/32",
    "141.237.236.10/32"
  ]
  description = "List of IPs allowed to SSH into EC2"
}

variable "windows_ip"{
    default = ["172.31.47.63/32"]   # "0.0.0.0/0"

    description = "Windows IP allowed to HTTP into website"
}