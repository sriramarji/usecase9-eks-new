resource "aws_ecs_cluster" "test" {
  name = var.name
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.name
  }
}

resource "aws_ecs_task_definition" "test_1" {
  family                 = "${var.name}-task-definition-1"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<TASK_DEFINITION
    [
    {
        "name": "test-container",
        "image": "${var.ecr_repo_url[0]}:latest",
        "cpu": 128,
        "memory": 128,
        "essential": true,
        "portMappings": [
            {
             "containerPort": 3001,
             "hostPort": 3001
            }
        ],
        "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group"         : "${var.appointment_service}",
          "awslogs-region"        : "${data.aws_region.current.name}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
    ]
    TASK_DEFINITION
  execution_role_arn       = var.ecs_role_arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  tags = {
    "Name" = "${var.name}-task1"
  }
}

resource "aws_ecs_task_definition" "test_2" {
  family                 = "${var.name}-task-definition-2"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<TASK_DEFINITION
    [
    {
        "name": "test-container",
        "image": "${var.ecr_repo_url[1]}:latest",
        "cpu": 128,
        "memory": 128,
        "essential": true,
        "portMappings": [
            {
             "containerPort": 3000,
             "hostPort": 3000
            }
        ],
        "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group"         : "${var.patient_service}",
          "awslogs-region"        : "${data.aws_region.current.name}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
    ]
    TASK_DEFINITION
  execution_role_arn       = var.ecs_role_arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  tags = {
    "Name" = "${var.name}-task2"
  }
}



resource "aws_ecs_service" "main_1" {
  name            = "${var.name}-service-1"
  cluster         = aws_ecs_cluster.test.id
  task_definition = aws_ecs_task_definition.test_1.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  load_balancer {
    target_group_arn = var.target[0]
    container_name   = "${var.name}-container"
    container_port   = 3001
  }

  network_configuration {
    subnets          = var.subnets
    security_groups = var.security_group_ids
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "main_2" {
  name            = "${var.name}-service-2"
  cluster         = aws_ecs_cluster.test.id
  task_definition = aws_ecs_task_definition.test_2.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  load_balancer {
    target_group_arn = var.target[1]
    container_name   = "${var.name}-container"
    container_port   = 3000
  }

  network_configuration {
    subnets          = var.subnets
    security_groups = var.security_group_ids
    assign_public_ip = true
  }
}

# Data source for current AWS region
data "aws_region" "current" {}