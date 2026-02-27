############################################
# Application Load Balancer
############################################

resource "aws_lb" "main" {
  name               = "task11-prod-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
  security_groups    = [aws_security_group.alb.id]
}

############################################
# BLUE Target Group
############################################

resource "aws_lb_target_group" "blue" {
  name        = "task11-blue"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

############################################
# GREEN Target Group
############################################

resource "aws_lb_target_group" "green" {
  name        = "task11-green"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path    = "/"
    matcher = "200-399"
  }
}

############################################
# Production Listener (Port 80)
############################################

resource "aws_lb_listener" "prod_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

############################################
# Test Listener (Required for CodeDeploy)
############################################

resource "aws_lb_listener" "test_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }
}