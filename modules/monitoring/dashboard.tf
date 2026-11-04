resource "aws_cloudwatch_dashboard" "infrastructure" {

  dashboard_name = "${var.project_name}-${var.environment}-infrastructure"

  dashboard_body = jsonencode({
    widgets = [

      # ------------------------------------------------
      # CPU utilisation
      # ------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "EC2 CPU Utilisation"
          view   = "timeSeries"
          region = data.aws_region.current.name

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              var.domain_controller_instance_id,
              {
                label = "Domain Controller"
              }
            ],
            [
              "...",
              var.windows_instance_id,
              {
                label = "Windows Server"
              }
            ],
            [
              "...",
              var.ubuntu_instance_id,
              {
                label = "Ubuntu Server"
              }
            ]
          ]

          period = 300
          stat   = "Average"
        }
      },

      # ------------------------------------------------
      # Network traffic
      # ------------------------------------------------

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "EC2 Network Traffic"
          view   = "timeSeries"
          region = data.aws_region.current.name

          metrics = [

            [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId",
              var.domain_controller_instance_id,
              {
                label = "DC Network In"
              }
            ],

            [
              "AWS/EC2",
              "NetworkOut",
              "InstanceId",
              var.domain_controller_instance_id,
              {
                label = "DC Network Out"
              }
            ],

            [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId",
              var.windows_instance_id,
              {
                label = "Windows Network In"
              }
            ],

            [
              "AWS/EC2",
              "NetworkOut",
              "InstanceId",
              var.windows_instance_id,
              {
                label = "Windows Network Out"
              }
            ],

            [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId",
              var.ubuntu_instance_id,
              {
                label = "Ubuntu Network In"
              }
            ],

            [
              "AWS/EC2",
              "NetworkOut",
              "InstanceId",
              var.ubuntu_instance_id,
              {
                label = "Ubuntu Network Out"
              }
            ]
          ]

          period = 300
          stat   = "Average"
        }
      },

      # ------------------------------------------------
      # DNS health
      # ------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {

          title = "Active Directory DNS Health"

          view   = "timeSeries"
          region = data.aws_region.current.name

          metrics = [
            [
              "DiplomaProject/Infrastructure",
              "AD_DNS_Health",
              "InstanceId",
              var.domain_controller_instance_id
            ]
          ]

          period = 300
          stat   = "Minimum"

          yAxis = {
            left = {
              min = 0
              max = 1
            }
          }
        }
      }
    ]
  })
}

data "aws_region" "current" {}