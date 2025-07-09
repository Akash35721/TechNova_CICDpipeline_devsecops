# In alerts.tf

#################################################################
#  DATA SOURCE: FIND THE EXISTING SNS TOPIC
#  This looks up the SNS Topic you created manually.
#  It is resilient because it doesn't manage a resource requiring
#  human confirmation.
#################################################################
data "aws_sns_topic" "technova_alerts_topic" {
  name = "TechNova-High-CPU-Alerts"
}

#################################################################
#  ALARM 1: HIGH CPU UTILIZATION (SENSITIVE FOR TESTING)
#################################################################
resource "aws_cloudwatch_metric_alarm" "high_cpu_test_alarm" {
  alarm_name          = "TechNova-High-CPU-Test"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  threshold           = 75
  period              = "60"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  dimensions = {
    InstanceId = aws_instance.technova_server.id
  }
  alarm_description = "TEST ALARM: CPU is 75% or higher for 1 minute."
  # This now refers to the topic found by the data source
  alarm_actions     = [data.aws_sns_topic.technova_alerts_topic.arn]
  ok_actions        = [data.aws_sns_topic.technova_alerts_topic.arn]
}

#################################################################
#  ALARM 2: HIGH NETWORK OUT (SENSITIVE FOR TESTING)
#################################################################
resource "aws_cloudwatch_metric_alarm" "high_network_out_test_alarm" {
  alarm_name          = "TechNova-High-Network-Out-Test"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Sum"
  threshold           = 5000000
  period              = "60"
  evaluation_periods  = "1"
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  dimensions = {
    InstanceId = aws_instance.technova_server.id
  }
  alarm_description = "TEST ALARM: Network Out is over 5MB in 1 minute."
  # This also refers to the topic found by the data source
  alarm_actions     = [data.aws_sns_topic.technova_alerts_topic.arn]
  ok_actions        = [data.aws_sns_topic.technova_alerts_topic.arn]
}



# to test actually run these comands in the terminal of ec2 

# // stress the cpu 
# # 1. Install the stress tool
# sudo apt-get update && sudo apt-get install -y stress

# # 2. Run a CPU stress test for 2 minutes
# #    This will definitely trigger your 75% CPU alarm.
# stress --cpu 2 --timeout 120s


# // for network 


# # Download a 10MB file to generate network traffic
# wget -O /dev/null http://speedtest.tele2.net/10MB.zip

    