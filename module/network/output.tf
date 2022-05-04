output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}

output "alb" {
  value = aws_lb.lb
}

output "lb_listener_https" {
  value = aws_lb_listener.https
}

output "lb_listener_test_https" {
  value = aws_lb_listener.test_https
}

output "target_group_blue" {
  value = aws_lb_target_group.tg_blue
}

output "target_group_green" {
  value = aws_lb_target_group.tg_green
}
