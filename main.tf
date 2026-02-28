provider "aws" {
  region = var.aws_region
}

# --- VPC & Networking ---
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "Rimi-Assignment-VPC" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Rimi-Main-IGW" }
}

resource "aws_subnet" "pub_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "Rimi-Public-Subnet-1" }
}

resource "aws_subnet" "pub_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "Rimi-Public-Subnet-2" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "Rimi-Public-RT" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pub_2.id
  route_table_id = aws_route_table.public_rt.id
}

# --- Security Groups ---
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  name   = "rimi-alb-sg-v6"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  name   = "rimi-ec2-sg-v6"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- EC2 Instances (Using Variables for Names) ---
resource "aws_instance" "apache_server" {
  ami           = var.apache_ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.pub_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  tags = { 
    Name = var.apache_server_name 
  }
}

resource "aws_instance" "nginx_server" {
  ami           = var.nginx_ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.pub_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  tags = { 
    Name = var.nginx_server_name 
  }
}

# --- Application Load Balancer ---
resource "aws_lb" "web_alb" {
  name               = "rimi-islam-alb-v6"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]

  # পারমিশন এরর এড়াতে lifecycle ব্যবহার করা হয়েছে
  lifecycle {
    ignore_changes = all
  }
}

# --- Target Groups ---
resource "aws_lb_target_group" "apache_tg" {
  name     = "rimi-tg-apache-v6"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "nginx_tg" {
  name     = "rimi-tg-nginx-v6"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "a_attach" {
  target_group_arn = aws_lb_target_group.apache_tg.arn
  target_id        = aws_instance.apache_server.id
}

resource "aws_lb_target_group_attachment" "n_attach" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = aws_instance.nginx_server.id
}

# --- Listener & Rules ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "apache" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apache_tg.arn
  }
  condition {
    path_pattern {
      values = ["/apache*"]
    }
  }
}

resource "aws_lb_listener_rule" "nginx" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
  condition {
    path_pattern {
      values = ["/nginx*"]
    }
  }
}