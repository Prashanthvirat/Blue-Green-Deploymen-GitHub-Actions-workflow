# ------------------------------------------------
# ECS Cluster
# ------------------------------------------------
resource "aws_ecs_cluster" "main" {
  name = "strapi-prod-cluster"
}

# ------------------------------------------------
# Task Definition
# ------------------------------------------------
resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-prod-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  # Points to the existing roles in your account to avoid 403 errors
  execution_role_arn = local.ecs_task_execution_role_arn
  task_role_arn      = local.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "strapi-container"
      image     = "811738710312.dkr.ecr.us-east-1.amazonaws.com/task11-prod-repo:latest"
      essential = true

      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" },
        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = aws_db_instance.strapi.address },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = "postgres" },
        { name = "DATABASE_USERNAME", value = "postgres" },
        { name = "DATABASE_PASSWORD", value = "StrapiPassword123!" },
        { name = "APP_KEYS", value = "appKey1,appKey2" },
        { name = "API_TOKEN_SALT", value = "tokenSalt" },
        { name = "ADMIN_JWT_SECRET", value = "adminSecret" },
        { name = "JWT_SECRET", value = "jwtSecret" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          # FIXED: Using the string name directly for the manually created group
          "awslogs-group"         = "/ecs/strapi-prod"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:1337/_health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}

# ------------------------------------------------
# ECS Service
# ------------------------------------------------
resource "aws_ecs_service" "strapi" {
  name            = "strapi-prod-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "strapi-container"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.prod_listener]
}