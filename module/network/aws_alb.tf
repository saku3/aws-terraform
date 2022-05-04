resource "aws_lb" "lb" {
  name               = "${var.project}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    "${aws_security_group.alb_sg.id}",
  ]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
  ]

  access_logs {
    enabled = true
    bucket  = var.lb_logs_bucket.id
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "403"
    }
  }

  certificate_arn = aws_acm_certificate.cert.arn
}

resource "aws_lb_listener" "test_https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "10443"
  protocol          = "HTTPS"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "403"
    }
  }

  certificate_arn = aws_acm_certificate.cert.arn
}

resource "aws_lb_listener_rule" "routing" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_blue.arn
  }

  condition {
    host_header {
      values = ["${var.domain}"]
    }
  }
  lifecycle {
    ignore_changes = [action]
  }
}

resource "aws_lb_listener_rule" "test_routing" {
  listener_arn = aws_lb_listener.test_https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_green.arn
  }

  condition {
    host_header {
      values = ["${var.domain}"]
    }
  }
  lifecycle {
    ignore_changes = [action]
  }
}

resource "aws_lb_target_group" "tg_blue" {
  name        = "${var.project}-${var.env}-blue-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    interval            = 60
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


resource "aws_lb_target_group" "tg_green" {
  name        = "${var.project}-${var.env}-green-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    interval            = 60
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}
