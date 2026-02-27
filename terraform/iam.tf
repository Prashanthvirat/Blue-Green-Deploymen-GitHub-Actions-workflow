# ─────────────────────────────────────────
# Using existing role ARNs directly
# No IAM read permissions needed
# ─────────────────────────────────────────
locals {
  account_id                  = "811738710312"
  ecs_task_execution_role_arn = "arn:aws:iam::${local.account_id}:role/ecs_fargate_taskRole"
  ecs_task_role_arn           = "arn:aws:iam::${local.account_id}:role/ecs_fargate_taskRole"
  codedeploy_role_arn         = "arn:aws:iam::${local.account_id}:role/codedeploy_role"
}