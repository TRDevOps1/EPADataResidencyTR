locals {
  instances = {
    domain-controller = var.domain_controller_instance_id
    windows           = var.windows_instance_id
    ubuntu            = var.ubuntu_instance_id
  }
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
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "missing"
}

# -----------------------------------------------------
# Custom Domain Controller DNS alarm
# -----------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "ad_dns_health" {

  alarm_name = "${var.project_name}-${var.environment}-ad-dns-health"

  alarm_description = "Active Directory DNS health check failed"

  namespace   = "AIGPoC/Infrastructure"
  metric_name = "AD_DNS_Health"

  dimensions = {
    InstanceId = var.domain_controller_instance_id
  }

  statistic           = "Minimum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"

  # If the DC stops publishing the metric,
  # consider that unhealthy.
  treat_missing_data = "breaching"
}