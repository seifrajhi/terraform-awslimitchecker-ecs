terraform {
  required_providers {

    datadog = {
      source = "datadog/datadog"
    }
  }
}


provider "aws" {
  region  = "eu-west-1"
}

provider "aws" {
  region  = "eu-west-2"
  version = "~> 2.0"
  alias   = "eu-west-2"
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

resource "aws_iam_role" "awslimitchecker" {
  name               = "awslimitchecker-fargate"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "awslimitchecker-events" {
  name               = "awslimitchecker-events"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

module "awslimitchecker-eu-west-1" {
  source = "./terraform-module"

  pagerduty_critical_service_key = "${var.pagerduty_critical_service_key}"
  datadog_notification_string    = "${var.datadog_notification_string}"
  datadog_api_key                = "${var.datadog_api_key}"
  account_alias                  = "${var.account_alias}"
  task_role_arn                  = "${aws_iam_role.awslimitchecker.arn}"
  task_role_id                   = "${aws_iam_role.awslimitchecker.id}"
  execution_role_arn             = "${aws_iam_role.awslimitchecker.arn}"
  execution_role_id              = "${aws_iam_role.awslimitchecker.id}"
  events_role_arn                = "${aws_iam_role.awslimitchecker-events.arn}"
  events_role_id                 = "${aws_iam_role.awslimitchecker-events.id}"
  tags                           = "${local.tags}"
  tooling_repo                   = "${local.tags["tooling_repo"]}"
  security_groups                = ["${var.security_group_ids}"]
  subnet_ids                     = ["${var.internal_subnet_ids}"]
}

module "awslimitchecker-eu-west-2" {
  source = "./terraform-module"

  pagerduty_critical_service_key = "${var.pagerduty_critical_service_key}"
  datadog_notification_string    = "${var.datadog_notification_string}"
  datadog_api_key                = "${var.datadog_api_key}"
  account_alias                  = "${var.account_alias}"
  task_role_arn                  = "${aws_iam_role.awslimitchecker.arn}"
  task_role_id                   = "${aws_iam_role.awslimitchecker.id}"
  execution_role_arn             = "${aws_iam_role.awslimitchecker.arn}"
  execution_role_id              = "${aws_iam_role.awslimitchecker.id}"
  events_role_arn                = "${aws_iam_role.awslimitchecker-events.arn}"
  events_role_id                 = "${aws_iam_role.awslimitchecker-events.id}"
  tags                           = "${local.tags}"
  tooling_repo                   = "${local.tags["tooling_repo"]}"
  security_groups                = ["${var.security_group_ids}"]
  subnet_ids                     = ["${var.internal_subnet_ids}"]
  attach_policies                = "0"  # needed on all instances of module after the first
  attach_events_policies         = "0"  # needed on all instances of module after the first
  providers = {
    aws = aws.eu-west-2
  }
}