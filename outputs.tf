# লোড ব্যালেন্সারের মেইন ডিএনএস (DNS) নাম
output "alb_dns_link" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.web_alb.dns_name
}

#  অ্যাপাচি সার্ভার চেক 
output "apache_url" {
  description = "Link to Apache Server"
  value       = "http://${aws_lb.web_alb.dns_name}/apache"
}

# এনজিনেক্স সার্ভার চেক 
output "nginx_url" {
  description = "Link to Nginx Server"
  value       = "http://${aws_lb.web_alb.dns_name}/nginx"
}