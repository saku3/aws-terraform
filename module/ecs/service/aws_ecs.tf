resource "aws_ecs_service" "main" {
  name                              = "${var.project}-${var.env}-${var.app_name}"
  cluster                           = var.cluster.id
  task_definition                   = aws_ecs_task_definition.main.arn
  platform_version                  = "1.4.0"
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 200
  enable_execute_command            = true

  network_configuration {
    subnets          = [var.private_subnet_1_id, var.private_subnet_2_id]
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = "false"
  }

  load_balancer {
    target_group_arn = var.target_group_blue_arn
    container_name   = "${var.project}-${var.env}-${var.app_name}"
    container_port   = var.container_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.app_name}"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
      load_balancer,
    ]
  }

  depends_on = [var.alb]
}

resource "aws_ecs_task_definition" "main" {
  family = "${var.project}-${var.env}-${var.app_name}"

  requires_compatibilities = [
    "FARGATE"
  ]

  cpu    = 256
  memory = 512

  network_mode = "awsvpc"

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("../../module/ecs/service/json/container_definitions.tpl.json",
    {
      account_id     = var.current_id,
      project        = var.project
      app_name       = var.app_name,
      env            = var.env,
      container_port = var.container_port
    }
  )
}