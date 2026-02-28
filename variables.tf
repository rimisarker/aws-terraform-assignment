
variable "aws_region" {
  default = "us-west-2"
}

variable "apache_ami_id" {
  default = "ami-01c661efb9db1ee8e" 
}

variable "nginx_ami_id" {
  default = "ami-0419e888a6fb9893b" 
}

variable "instance_type" {
  default = "t3a.micro"
}

# ---  প্র্যাকটিসের জন্য নতুন ভেরিয়েবল ---
variable "apache_server_name" {
  default = "rimi-islam-apache-server"
}

variable "nginx_server_name" {
  default = "rimi-islam-nginx-server"
}