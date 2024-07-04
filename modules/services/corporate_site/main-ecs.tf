# -----------------------------------------
# ECS Cluster
# -----------------------------------------
resource "aws_ecs_cluster" "corporate_ecs_cluster" {
  name = "corporate_${var.environment}_ecs_cluster"

  tags = {
    name = "corporate_${var.environment}_ecs_cluster"
  }
}

# タスク定義
resource "aws_ecs_task_definition" "corporate_ecs_task_definition" {
  family                   = "corporate_${var.environment}_ecs_task_definition"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("${path.module}/container_definitions.tftpl", {
    environment     = var.environment,
    aws_account_id  = var.aws_account_id,
    repository_name = var.repository_name
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}


# ECS サービス
resource "aws_ecs_service" "corporate_ecs_service" {
  name                              = "corporate_${var.environment}_ecs_service"
  cluster                           = aws_ecs_cluster.corporate_ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.corporate_ecs_task_definition.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60

  depends_on = [aws_lb_listener_rule.ecs]

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.corporate_ecs_service.id]
    subnets          = aws_subnet.private[*].id
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = "corporate_${var.environment}_ecs_container"
    container_port   = 80
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}

# -----------------------------------------
# Security Group for ECS
# -----------------------------------------
resource "aws_security_group" "corporate_ecs_service" {
  name   = "corporate_${var.environment}_ecs_service"
  vpc_id = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "ecs_ingress" {
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = aws_vpc.this.cidr_block
  security_group_id = aws_security_group.corporate_ecs_service.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.corporate_ecs_service.id
}

# -----------------------------------------
# IAM Role for ECS
# -----------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "MyEcsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "amazon_ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
