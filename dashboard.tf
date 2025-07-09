# In a new file, e.g., dashboard.tf

resource "aws_cloudwatch_dashboard" "technova_dashboard" {
  dashboard_name = "TechNova_Performance_Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            # Note: This now correctly references aws_instance.technova_server.id
            ["CWAgent", "cpu_usage_idle", "InstanceId", aws_instance.technova_server.id, { "label" = "CPU Idle", "color" = "#2ca02c" }],
            [".", "cpu_usage_user", ".", ".", { "label" = "CPU User", "color" = "#1f77b4" }],
            [".", "cpu_usage_system", ".", ".", { "label" = "CPU System", "color" = "#ff7f0e" }]
          ],
          period = 300,
          stat   = "Average",
          region = "us-east-1", # Change to your AWS region
          title  = "CPU Utilization (%)"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            # Note: This now correctly references aws_instance.technova_server.id
            ["CWAgent", "mem_used_percent", "InstanceId", aws_instance.technova_server.id]
          ],
          period = 300,
          stat   = "Average",
          region = "us-east-1", # Change to your AWS region
          title  = "Memory Utilization (%)"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 7,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            # Note: This now correctly references aws_instance.technova_server.id
            ["CWAgent", "disk_used_percent", "path", "/", "InstanceId", aws_instance.technova_server.id]
          ],
          period = 300,
          stat   = "Average",
          region = "us-east-1", # Change to your AWS region
          title  = "Disk Utilization (%)"
        }
      }
    ]
  })
}