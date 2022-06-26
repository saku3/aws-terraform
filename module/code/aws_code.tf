resource "aws_codebuild_project" "main" {
  name          = "${var.project}-${var.env}-${var.app_name}-codebuild-project"
  description   = "${var.project}-${var.env}-${var.app_name}-codebuild-project"
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type     = "S3"
    location = var.codepipeline_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.ecr_repository_url
    }
    environment_variable {
      name  = "ARTIFACTS_BUCKET"
      value = var.codepipeline_bucket.bucket
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/codebuild/${var.app_name}/log"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.repository}.git"
    git_clone_depth = 0
    buildspec       = "deployments/buildspec.yml"
  }

  source_version = var.source_version
}


resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project}-${var.env}-${var.app_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]
      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.connection.arn
        FullRepositoryId = var.repository
        BranchName       = var.source_version
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      version          = "1"
      run_order        = 2

      configuration = {
        ProjectName = aws_codebuild_project.main.name
        EnvironmentVariables = jsonencode([
          { "name" : "REPOSITORY_URI", "value" : "${var.ecr_repository_url}" },
          { "name" : "ENV", "value" : "${var.env}" },
          { "name" : "ACCOUNT_ID", "value" : "${var.current_id}" },
          { "name" : "TASK_ROLE_ARN", "value" : "${var.ecs_task_role.arn}" },
          { "name" : "EXECUTION_ROLE_ARN", "value" : "${var.ecs_task_execution_role.arn}" },
          { "name" : "LOGGROUP_NAME", "value" : "${var.ecs_task_log_group.name}" },
          { "name" : "TASK_FAMILY", "value" : "${var.task_definition.family}" },
          { "name" : "CONTAINER_NAME", "value" : "${var.project}-${var.env}-${var.app_name}" },
          { "name" : "CONTAINER_PORT", "value" : "${var.container_port}" }
        ])
      }
    }

  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["build"]
      version         = "1"
      run_order       = 3

      configuration = {
        ApplicationName                = var.codedeploy_app.name,
        DeploymentGroupName            = var.codedeploy_deployment_group.deployment_group_name
        TaskDefinitionTemplateArtifact = "build"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "build"
        AppSpecTemplatePath            = "appspec.yaml"
        Image1ArtifactName             = "build"
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }
}
