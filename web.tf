###
# Security group.
###
resource "aws_security_group" "sg_web" {
    name        = "sg_ec2-web"
    description = "Managed by Terraform"
    vpc_id      = aws_vpc.projet_annuel.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port   = 22
        to_port     = 22
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

###
# Launch configuration.
###
resource "aws_launch_configuration" "lc-web" {
    name_prefix     = "lc-web"
    image_id        = data.aws_ami.ubuntu.id
    instance_type   = "t2.micro"
    key_name        = "ubuntu-theo"
    security_groups = [aws_security_group.sg_web.id]
    user_data       = data.template_cloudinit_config.cloudinit.rendered

    lifecycle {
        create_before_destroy = true
    }

    root_block_device{
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }
}

###
# Autoscaling group.
###
resource "aws_autoscaling_group" "asg-web" {
    name                      = "asg_web"
    max_size                  = 2
    min_size                  = 2
    desired_capacity          = 2
    health_check_grace_period = 300
    health_check_type         = "EC2"
    force_delete              = true
    launch_configuration      = aws_launch_configuration.lc-web.name
    vpc_zone_identifier       = [aws_subnet.private1.id, aws_subnet.private2.id]
    target_group_arns         = [aws_lb_target_group.http.arn, aws_lb_target_group.http.arn]
    
    lifecycle {
        create_before_destroy = true
    }
}

###
# Target group.
###
resource "aws_lb_target_group" "http" {
  name     = "http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.projet_annuel.id
}

###
# Application Load Balance.
###
resource "aws_lb" "alb" {
    name               = "web"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.sg_web.id]
    subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
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

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:eu-west-3:048995984726:certificate/74b49396-b2d7-497d-9c8f-c5e104e53717"
  ssl_policy        = "ELBSecurityPolicy-FS-2018-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.id
  }
}

###
# R53.
###
resource "aws_route53_record" "r53" {
  zone_id         = "Z069104211F62KIIEBR7P"
  name            = "techzoneonline.fr."
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}