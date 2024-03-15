variable "instance_id" {}
variable "private_subnet_1" {}
variable "lb-sg" {}

resource "aws_elb" "pj-mgr-lb" {
  name               = "pj-mgr-lb"

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = ["${var.instance_id}"]
  security_groups             = ["${var.lb-sg}"]
  subnets                     = ["${var.private_subnet_1}"]

  cross_zone_load_balancing   = false
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}