# ECS クラスター
resource "aws_ecs_cluster" "corperate-ecs-cluster" {
  name = "corperate-ecs-cluster"

  tags = {
    name = "corperate-ecs-cluster"
  }
}

# タスク定義
resource "aws_ecs_task_definition" "corperate-ecs-task-definition" {
  family                   = "corperate"
  cpu                      = "4096"
  memory                   = "2048"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      "name" : "corperate-ecs-container",
      # "image" : "nginx:1.21.1",
      "image" : "[AWS_ACCOUNT_ID].dkr.ecr.ap-northeast-1.amazonaws.com/corporate-container:latest", // ECRのリポジトリを指定する。
      "essential" : true,
      "portMappings" : [
        {
          "protocol" : "tcp",
          "containerPort" : 80
        }
      ]
    }
  ])
}

# ECS サービス
resource "aws_ecs_service" "corperate_ecs_service" {
  name                              = "corperate_ecs_service"
  cluster                           = aws_ecs_cluster.corperate-ecs-cluster.arn
  task_definition                   = aws_ecs_task_definition.corperate-ecs-task-definition.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60
  network_configuration {
    assign_public_ip = false
    security_groups  = [module.nginx_sg.security_group_id]
    subnets          = aws_subnet.private[*].id
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = "example"
    container_port   = 80
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}

# Security Group
module "nginx_sg" {
  source     = "../../security_group"
  name       = "nginx-sg"
  vpc_id     = aws_vpc.this.id
  port       = 80
  cidr_block = aws_vpc.this.cidr_block
}
