data "aws_region" "current" {}

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
          region = data.aws_region.current.region

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

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
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
          region = data.aws_region.current.region

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
      # Disk I/O operations
      # ------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "EC2 Disk I/O Operations"
          view   = "timeSeries"
          region = data.aws_region.current.region

          metrics = [
            [
              "AWS/EC2",
              "DiskReadOps",
              "InstanceId",
              var.domain_controller_instance_id,
              {
                label = "DC Disk Reads"
              }
            ],
            [
              "AWS/EC2",
              "DiskWriteOps",
              "InstanceId",
              var.domain_controller_instance_id,
              {
                label = "DC Disk Writes"
              }
            ],
            [
              "AWS/EC2",
              "DiskReadOps",
              "InstanceId",
              var.windows_instance_id,
              {
                label = "Windows Disk Reads"
              }
            ],
            [
              "AWS/EC2",
              "DiskWriteOps",
              "InstanceId",
              var.windows_instance_id,
              {
                label = "Windows Disk Writes"
              }
            ],
            [
              "AWS/EC2",
              "DiskReadOps",
              "InstanceId",
              var.ubuntu_instance_id,
              {
                label = "Ubuntu Disk Reads"
              }
            ],
            [
              "AWS/EC2",
              "DiskWriteOps",
              "InstanceId",
              var.ubuntu_instance_id,
              {
                label = "Ubuntu Disk Writes"
              }
            ]
          ]

          period = 300
          stat   = "Sum"
        }
      },

      # ------------------------------------------------
      # EC2 status checks
      # ------------------------------------------------

      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "EC2 Status Checks"
          view   = "timeSeries"
          region = data.aws_region.current.region

          metrics = [
            [
              "AWS/EC2",
              "StatusCheckFailed",
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

          period = 60
          stat   = "Maximum"

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