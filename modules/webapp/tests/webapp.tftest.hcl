mock_provider "aws" {}

variables {
  vpc_id = "vpc-12345678"

  public_subnet_ids = [
    "subnet-11111111",
    "subnet-22222222"
  ]
}

run "ecs_service_configuration" {
  command = plan

  assert {
    condition     = aws_ecs_service.webapp.desired_count == 2
    error_message = "ECS service should run two tasks."
  }

  assert {
    condition     = aws_ecs_service.webapp.launch_type == "FARGATE"
    error_message = "ECS service must use the FARGATE launch type."
  }
}

run "load_balancer_configuration" {
  command = plan

  assert {
    condition     = aws_lb_listener.http.port == 80
    error_message = "ALB listener should listen on port 80."
  }

  assert {
    condition     = aws_lb_listener.http.protocol == "HTTP"
    error_message = "ALB listener should use HTTP."
  }

  assert {
    condition     = aws_lb_target_group.web.port == 80
    error_message = "Target group should forward traffic to port 80."
  }

  assert {
    condition     = aws_lb_target_group.web.target_type == "ip"
    error_message = "Target group must use IP targets for ECS Fargate."
  }
}