variable "cloudwatch_sns_topic_arn" {}

resource "aws_cloudwatch_metric_alarm" "storage" {
  alarm_name          = "db-${var.name}-freestoragespace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10000000000"

  dimensions = {
    DBInstanceIdentifier = "${var.name}"
  }

  alarm_actions     = [var.cloudwatch_sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "db-${var.name}-cpuutilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "10"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"

  dimensions = {
    DBInstanceIdentifier = "${var.name}"
  }

  alarm_actions     = [var.cloudwatch_sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "readlatency" {
  alarm_name          = "db-${var.name}-readlatency"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "2"
  threshold_metric_id = "ad1"
  datapoints_to_alarm = "2"

  metric_query {
    id          = "m1"
    return_data = true

    metric {
        dimensions  = {
            "DBInstanceIdentifier" = "${var.name}"
        }
        metric_name = "ReadLatency"
        namespace   = "AWS/RDS"
        period      = 300
        stat        = "Average"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 1000)"
    id          = "ad1"
    label       = "ReadLatency (expected)"
    return_data = true
  }

  alarm_actions     = [var.cloudwatch_sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "writelatency" {
  alarm_name          = "db-${var.name}-writelatency"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "2"
  threshold_metric_id = "ad1"
  datapoints_to_alarm = "2"

  metric_query {
    id          = "m1"
    return_data = true

    metric {
        dimensions  = {
            "DBInstanceIdentifier" = "${var.name}"
        }
        metric_name = "WriteLatency"
        namespace   = "AWS/RDS"
        period      = 300
        stat        = "Average"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 1000)"
    id          = "ad1"
    label       = "WriteLatency (expected)"
    return_data = true
  }

  alarm_actions     = [var.cloudwatch_sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "transactionlogsdiskusage" {
  alarm_name          = "db-${var.name}-transactionlogsdiskusage"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "2"
  threshold_metric_id = "ad1"
  datapoints_to_alarm = "2"

  metric_query {
    id          = "m1"
    return_data = true

    metric {
        dimensions  = {
            "DBInstanceIdentifier" = "${var.name}"
        }
        metric_name = "TransactionLogsDiskUsage"
        namespace   = "AWS/RDS"
        period      = 300
        stat        = "Average"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 100)"
    id          = "ad1"
    label       = "WriteLatency (expected)"
    return_data = true
  }

  alarm_actions     = [var.cloudwatch_sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "transactionlogsgeneration" {
  alarm_name          = "db-${var.name}-transactionlogsgeneration"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "2"
  threshold_metric_id = "ad1"
  datapoints_to_alarm = "2"

  metric_query {
    id          = "m1"
    return_data = true

    metric {
        dimensions  = {
            "DBInstanceIdentifier" = "${var.name}"
        }
        metric_name = "TransactionLogsGeneration"
        namespace   = "AWS/RDS"
        period      = 300
        stat        = "Average"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 3000)"
    id          = "ad1"
    label       = "WriteLatency (expected)"
    return_data = true
  }

  alarm_actions     = [var.cloudwatch_sns_topic_arn]
}
