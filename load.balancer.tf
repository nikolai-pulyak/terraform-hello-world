resource "aws_lb" "lb-hello-world" {
  name = "name-lb-hello-world"
  internal = false
  load_balancer_type = "application"
  ip_address_type = "ipv4"

  security_groups = [aws_security_group.sc-hello-world.id]

  subnets = [
    aws_subnet.subnet-hello-world-A.id,
    aws_subnet.subnet-hello-world-B.id
  ]
}