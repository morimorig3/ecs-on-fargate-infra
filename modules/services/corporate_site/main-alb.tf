# -----------------------------------------
# Application Load Balancer
# -----------------------------------------
resource "aws_lb" "this" {
  name               = "${var.environment}-alb"
  load_balancer_type = "application" # ロードバランサーの種別を設定します。application を指定すると ALB, network を指定すると NLB になります。
  internal           = false         # インターネット向けなのか VPC 内部向けなのかを指定します。false にするとインターネット向けになります。
  idle_timeout       = 60            # セッションのタイムアウト時間(秒)を設定します。
  # enable_deletion_protection = var.environment == "prod" ? true : false # 削除保護を有効にするか否かを指定します。本番環境では誤って削除しないよう true を指定します。
  enable_deletion_protection = false
  # ALB が所属するサブネットを指定します。
  subnets = aws_subnet.public[*].id
  # バケット名を指定して、アクセスログの保存を有効にします。
  # access_logs {
  #   bucket  = aws_s3_bucket.alb_log_bucket.bucket
  #   prefix  = "alb-log"
  #   enabled = true
  # }
  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
  ]
}

# -----------------------------------------
# Security Group
# -----------------------------------------
module "http_sg" {
  source     = "../../security_group"
  name       = "http-sg"
  vpc_id     = aws_vpc.this.id
  port       = 80
  cidr_block = "0.0.0.0/0"
}

module "https_sg" {
  source     = "../../security_group"
  name       = "https-sg"
  vpc_id     = aws_vpc.this.id
  port       = 443
  cidr_block = "0.0.0.0/0"
}

# -----------------------------------------
# Listener
# -----------------------------------------
# 80 番ポートで HTTP プロトコルのリクエストを受け付け、リクエストを 443 番ポートに転送
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# 443 番ポートでは HTTPS プロトコルのリクエストを受け付け、固定の HTTP レスポンスを返却
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn_tokyo
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "これは「HTTPS」です"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "ecs" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# -----------------------------------------
# Target Group
# -----------------------------------------
resource "aws_lb_target_group" "ecs" {
  name                 = "corporate-ecs-target-group"
  target_type          = "ip"
  vpc_id               = aws_vpc.this.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300
  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }
  depends_on = [aws_lb.this]
}
