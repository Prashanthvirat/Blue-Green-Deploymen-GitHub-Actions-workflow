# ==================================================
# CodeDeploy Application
# ==================================================
resource "aws_codedeploy_app" "strapi" {
  compute_platform = "ECS"
  name             = "strapi-prod-app"
}

# ==================================================
# CodeDeploy Deployment Group
# ==================================================
resource "aws_codedeploy_deployment_group" "strapi_group" {
  app_name               = aws_codedeploy_app.strapi.name
  deployment_group_name  = "strapi-prod-group"

  # FIXED: Now using the local variable to bypass IAM permission issues
  service_role_arn       = local.codedeploy_role_arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  # --------------------------------------------------
  # Blue/Green Settings
  # --------------------------------------------------
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  # --------------------------------------------------
  # ECS Service
  # --------------------------------------------------
  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.strapi.name
  }

  # --------------------------------------------------
  # Load Balancer Configuration
  # --------------------------------------------------
  load_balancer_info {
    target_group_pair_info {
      # BLUE & GREEN target groups
      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }

      # Production listener (Port 80)
      prod_traffic_route {
        listener_arns = [aws_lb_listener.prod_listener.arn]
      }

      # Test listener (Port 8080)
      test_traffic_route {
        listener_arns = [aws_lb_listener.test_listener.arn]
      }
    }
  }

  # --------------------------------------------------
  # Auto Rollback
  # --------------------------------------------------
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_STOP_ON_REQUEST"]
  }

  depends_on = [
    aws_lb_listener.prod_listener,
    aws_lb_listener.test_listener
  ]
}