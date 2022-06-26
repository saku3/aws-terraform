resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project}-${var.env}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project}-${var.env}-taskexec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_ssm_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_managed_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "ecs_autoscaling_role" {
  name               = "${var.project}-${var.env}-autoscaling-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_autoscaling_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_auto_scaling" {
  role       = aws_iam_role.ecs_autoscaling_role.name
  policy_arn = aws_iam_policy.ecs_autoscaling_policy.arn
}

data "aws_iam_policy_document" "ecs_autoscaling_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "application-autoscaling.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "ecs_autoscaling_policy" {
  name        = "${var.project}-ecs-autoscaling-policy"
  description = "ecs autoscaling policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "aplication-autoscaling:*",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm",
        "ecs:DescribeServices",
        "ecs:UpdateService"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
