data "aws_caller_identity" "me" {}

variable "prefix" {
  type = string
  default = null
}
variable "role_arns" {
  type = list(string)
}

resource "aws_sns_topic" "alerts" {
  name = "assume-role-alerts"
}
data "aws_iam_policy_document" "alerts" {
  // This is the default policy that allows the account to publish to the topic.
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = ["sns:Publish"]
    resources = [aws_sns_topic.alerts.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [data.aws_caller_identity.me.account_id]
    }
  }
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = ["sns:Publish"]
    resources = [aws_sns_topic.alerts.arn]
  }
}
resource "aws_sns_topic_policy" "alerts" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.alerts.json
}

data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

resource "aws_cloudwatch_event_rule" "assume_role" {
  event_bus_name = data.aws_cloudwatch_event_bus.default.name
  name = "assume-role-alerts"
  description = "Provides notifications when certain roles are assumed."
  state = "ENABLED"
  event_pattern = jsonencode({
    "detail": {
      "eventName": ["AssumeRole", "AssumeRoleWithSAML", "AssumeRoleWithWebIdentity"],
      "eventSource": ["sts.amazonaws.com"],
      "requestParameters": {"roleArn": var.role_arns}
    },
    "detail-type": ["AWS API Call via CloudTrail"],
    "source": ["aws.sts"]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  arn  = aws_sns_topic.alerts.arn
  rule = aws_cloudwatch_event_rule.assume_role.name
  input_transformer {
    input_paths = {
      "role" = "$.detail.requestParameters.roleArn",
      "user" = "$.detail.requestParameters.roleSessionName",
    }
    input_template = "\"Role <role> has been assumed by <user>\""
  }
}
