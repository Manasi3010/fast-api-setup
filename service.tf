resource "aws_ecs_service" "fastapi_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.fastapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnet_ids.selected.ids
    security_groups  = [aws_security_group.fastapi_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.fastapi_tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  depends_on = [aws_lb_listener.fastapi_listener]
}