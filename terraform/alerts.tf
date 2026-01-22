resource "google_monitoring_alert_policy" "bindplane_alerts" {
  display_name = "bindplane-alerts-${random_id.suffix.hex}"

  combiner = "OR"
  conditions {
    display_name = "CPU usage high"
    condition_threshold {
      filter = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
      comparison = "COMPARISON_GT"
      threshold_value = 0.8
      duration = "60s"
    }
  }

  notification_channels = [var.alert_email]
}
