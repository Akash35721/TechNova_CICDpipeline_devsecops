# In alerts.tf

#################################################################
#  NOTIFICATION CHANNEL (SNS)
#  This sends alerts to the email you have in your GitHub Secrets.
#################################################################
resource "aws_sns_topic" "technova_alerts_topic" {
  name = "TechNova-Performance-Alerts"
}


resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.technova_alerts_topic.arn
  protocol  = "email"

  endpoint  = "your-email@example.com"
}


#################################################################
#  ALARM 1: HIGH CPU UTILIZATION (SENSITIVE FOR TESTING)
#  Triggers if average CPU is over 75% for just 1 minute.
#################################################################
resource "aws_cloudwatch_metric_alarm" "high_cpu_test_alarm" {
  alarm_name          = "TechNova-High-CPU-Test"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  threshold           = 75 # Trigger at 75% CPU

  # ----- Settings for Rapid Testing -----
  period              = "60"  # Check every 60 seconds
  evaluation_periods  = "1"   # Trigger after 1 period (1 minute)
  # ------------------------------------

  # ----- Metric Details -----
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  dimensions = {
    InstanceId = aws_instance.technova_server.id
  }
  # -------------------------

  alarm_description = "TEST ALARM: CPU is 75% or higher for 1 minute."
  alarm_actions     = [aws_sns_topic.technova_alerts_topic.arn]
  ok_actions        = [aws_sns_topic.technova_alerts_topic.arn]
}


#################################################################
#  ALARM 2: HIGH NETWORK OUT (SENSITIVE FOR TESTING)
#  Triggers if network output exceeds 5 MB in 1 minute.
#################################################################
resource "aws_cloudwatch_metric_alarm" "high_network_out_test_alarm" {
  alarm_name          = "TechNova-High-Network-Out-Test"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Sum"
  # Trigger if more than 5,000,000 bytes (5 MB) are sent out
  threshold           = 5000000 

  # ----- Settings for Rapid Testing -----
  period              = "60" # Check every 60 seconds
  evaluation_periods  = "1"  # Trigger after 1 period (1 minute)
  # ------------------------------------

  # ----- Metric Details -----
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  dimensions = {
    InstanceId = aws_instance.technova_server.id
  }
  # -------------------------
  
  alarm_description = "TEST ALARM: Network Out is over 5MB in 1 minute."
  alarm_actions     = [aws_sns_topic.technova_alerts_topic.arn]
  ok_actions        = [aws_sns_topic.technova_alerts_topic.arn]
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
