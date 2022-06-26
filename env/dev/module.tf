module "vpc" {
  source             = "../../module/network"
  project            = var.project
  env                = var.env
  domain             = "${var.sub_domain}.${var.domain}"
  data_source_domain = var.domain
  lb_logs_bucket     = module.s3.lb_logs_bucket
}

module "ecr" {
  source   = "../../module/ecr"
  project  = var.project
  env      = var.env
  app_name = local.app_name
}

module "cluster" {
  source  = "../../module/ecs/cluster"
  project = var.project
  env     = var.env
}

module "ecs_service" {
  source         = "../../module/ecs/service"
  project        = var.project
  env            = var.env
  app_name       = local.app_name
  desired_count  = 1
  container_port = local.container_port

  alb                   = module.vpc.alb
  cluster               = module.cluster.ecs_cluster
  ecs_sg_id             = module.vpc.ecs_sg_id
  private_subnet_1_id   = module.vpc.private_subnet_1_id
  private_subnet_2_id   = module.vpc.private_subnet_2_id
  target_group_blue_arn = module.vpc.target_group_blue.arn
  ecr_repository_name   = module.ecr.ecr_repository.name
  current_id            = data.aws_caller_identity.current.id
}

module "code" {
  source                      = "../../module/code"
  project                     = var.project
  env                         = var.env
  repository                  = "saku3/golang-app"
  source_version              = "develop"
  ecr_repository_url          = module.ecr.ecr_repository.repository_url
  app_name                    = local.app_name
  codepipeline_bucket         = module.s3.codepipeline_bucket
  current_id                  = data.aws_caller_identity.current.id
  ecs_task_role               = module.ecs_service.ecs_task_role
  ecs_task_execution_role     = module.ecs_service.ecs_task_execution_role
  ecs_task_log_group          = module.log.ecs_task_log_group
  task_definition             = module.ecs_service.task_definition
  container_port              = local.container_port
  codestarconnections_arn     = var.codestarconnections_arn
  codedeploy_app              = module.deploy.codedeploy_app
  codedeploy_deployment_group = module.deploy.codedeploy_deployment_group
}

module "deploy" {
  source                     = "../../module/deploy"
  project                    = var.project
  env                        = var.env
  target_group_blue_name     = module.vpc.target_group_blue.name
  target_group_green_name    = module.vpc.target_group_green.name
  lb_listener_https_arn      = module.vpc.lb_listener_https.arn
  lb_listener_test_https_arn = module.vpc.lb_listener_test_https.arn
  ecs_cluster_name           = module.cluster.ecs_cluster.name
  ecs_service_name           = module.ecs_service.ecs_service.name
  app_name                   = local.app_name
}


module "s3" {
  source     = "../../module/s3"
  project    = var.project
  env        = var.env
  current_id = data.aws_caller_identity.current.id
}

module "log" {
  source   = "../../module/log"
  project  = var.project
  env      = var.env
  app_name = local.app_name
}
