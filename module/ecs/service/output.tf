output "ecs_service" {
  value = aws_ecs_service.main
}

output "task_definition" {
  value = aws_ecs_task_definition.main
}

output "ecs_task_role" {
  value = aws_iam_role.ecs_task_role
}

output "ecs_task_execution_role" {
  value = aws_iam_role.ecs_task_execution_role
}