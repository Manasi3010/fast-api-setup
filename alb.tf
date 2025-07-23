resource "aws_lb" "fastapi_alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.selected.ids
  security_groups    = [aws_security_group.fastapi_sg.id]
}

resource "aws_lb_target_group" "fastapi_tg" {
  name     = "${var.app_name}-tg"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "fastapi_listener" {
  load_balancer_arn = aws_lb.fastapi_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi_tg.arn
  }
}

resource "aws_lb" "fastapi_nlb" {
  name               = "${var.app_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.selected.ids
}