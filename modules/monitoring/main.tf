locals {
  instances = {
    domain-controller = var.domain_controller_instance_id
    windows           = var.windows_instance_id
    ubuntu            = var.ubuntu_instance_id
  }

  resource_name_prefix = lower(
    replace(
      "${var.project_name}-${var.environment}",
      "/[^a-zA-Z0-9-]/",
      "-"
    )
  )
}

# -----------------------------------------------------
# CPU alarms
# -----------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each = local.instances

  alarm_name        = "${var.project_name}-${var.environment}-${each.key}-cpu-high"
  alarm_description = "CPU utilisation exceeded 80% on ${each.key}"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    InstanceId = each.value
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "missing"
}

# -----------------------------------------------------
# EC2 status check alarms
# -----------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "status_check" {
  for_each = local.instances

  alarm_name        = "${var.project_name}-${var.environment}-${each.key}-status-check"
  alarm_description = "EC2 status check failed on ${each.key}"

  namespace   = "AWS/EC2"
  metric_name = "StatusCheckFailed"

  dimensions = {
    InstanceId = each.value
  }

  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "missing"
}