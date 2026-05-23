# --- Dashboards ---

resource "datadog_dashboard_json" "api_latency" {
  count = var.enable ? 1 : 0

  dashboard = jsonencode({
    title       = "Workshop - API Latency"
    description = "p50/p95/p99 latency of workshop-app endpoints"
    layout_type = "ordered"
    widgets = [
      {
        definition = {
          type  = "timeseries"
          title = "Request Latency (p50/p95/p99)"
          requests = [
            {
              q            = "p50:trace.http.server.request{service:${var.service_name}} by {resource_name}"
              display_type = "line"
              style        = { palette = "cool" }
            },
            {
              q            = "p95:trace.http.server.request{service:${var.service_name}} by {resource_name}"
              display_type = "line"
              style        = { palette = "warm" }
            },
            {
              q            = "p99:trace.http.server.request{service:${var.service_name}} by {resource_name}"
              display_type = "line"
              style        = { palette = "orange" }
            }
          ]
        }
      }
    ]
  })
}

resource "datadog_dashboard_json" "kubernetes_resources" {
  count = var.enable ? 1 : 0

  dashboard = jsonencode({
    title       = "Workshop - Kubernetes Resources"
    description = "CPU/memory by namespace, pod count, restarts"
    layout_type = "ordered"
    widgets = [
      {
        definition = {
          type  = "timeseries"
          title = "CPU Usage by Namespace"
          requests = [
            {
              q            = "avg:kubernetes.cpu.usage.total{kube_namespace:stag OR kube_namespace:prod} by {kube_namespace}"
              display_type = "line"
            }
          ]
        }
      },
      {
        definition = {
          type  = "timeseries"
          title = "Memory Usage by Namespace"
          requests = [
            {
              q            = "avg:kubernetes.memory.usage{kube_namespace:stag OR kube_namespace:prod} by {kube_namespace}"
              display_type = "line"
            }
          ]
        }
      },
      {
        definition = {
          type  = "timeseries"
          title = "Pod Restarts"
          requests = [
            {
              q            = "sum:kubernetes.containers.restarts{kube_namespace:stag OR kube_namespace:prod} by {kube_namespace,pod_name}.as_count()"
              display_type = "bars"
            }
          ]
        }
      }
    ]
  })
}

resource "datadog_dashboard_json" "health_uptime" {
  count = var.enable ? 1 : 0

  dashboard = jsonencode({
    title       = "Workshop - Health & Uptime"
    description = "/health success rate and uptime"
    layout_type = "ordered"
    widgets = [
      {
        definition = {
          type  = "query_value"
          title = "Health Endpoint Success Rate"
          requests = [
            {
              q          = "100 * (sum:trace.http.server.request.hits{service:${var.service_name},http.status_code:200}.as_count() / sum:trace.http.server.request.hits{service:${var.service_name}}.as_count())"
              aggregator = "avg"
            }
          ]
          precision = 2
        }
      },
      {
        definition = {
          type  = "timeseries"
          title = "Health Check Responses Over Time"
          requests = [
            {
              q            = "sum:trace.http.server.request.hits{service:${var.service_name}} by {http.status_code}.as_count()"
              display_type = "bars"
            }
          ]
        }
      }
    ]
  })
}

resource "datadog_dashboard_json" "business_orders" {
  count = var.enable ? 1 : 0

  dashboard = jsonencode({
    title       = "Workshop - Business Orders"
    description = "Daily order volume and average time per status"
    layout_type = "ordered"
    widgets = [
      {
        definition = {
          type  = "timeseries"
          title = "Work Orders Created (daily)"
          requests = [
            {
              q            = "sum:workshop_app_work_orders_created_total{*}.as_count().rollup(sum, 86400)"
              display_type = "bars"
            }
          ]
        }
      },
      {
        definition = {
          type  = "timeseries"
          title = "Status Changes"
          requests = [
            {
              q            = "sum:workshop_app_work_order_status_changes_total{*} by {from_status,to_status}.as_count()"
              display_type = "bars"
            }
          ]
        }
      },
      {
        definition = {
          type  = "timeseries"
          title = "Avg Duration per Status (seconds)"
          requests = [
            {
              q            = "avg:workshop_app_work_order_duration_seconds{*} by {status}"
              display_type = "line"
            }
          ]
        }
      }
    ]
  })
}

resource "datadog_dashboard_json" "errors_integrations" {
  count = var.enable ? 1 : 0

  dashboard = jsonencode({
    title       = "Workshop - Errors & Integrations"
    description = "5xx rate, integration errors, auth failures"
    layout_type = "ordered"
    widgets = [
      {
        definition = {
          type  = "timeseries"
          title = "5xx Error Rate"
          requests = [
            {
              q            = "sum:trace.http.server.request.errors{service:${var.service_name}}.as_count()"
              display_type = "bars"
              style        = { palette = "red" }
            }
          ]
        }
      },
      {
        definition = {
          type  = "timeseries"
          title = "Integration Errors"
          requests = [
            {
              q            = "sum:workshop_app_integration_errors_total{*} by {target}.as_count()"
              display_type = "bars"
            }
          ]
        }
      },
      {
        definition = {
          type  = "timeseries"
          title = "Auth Failures"
          requests = [
            {
              q            = "sum:workshop_app_auth_failures_total{*} by {reason}.as_count()"
              display_type = "bars"
              style        = { palette = "orange" }
            }
          ]
        }
      }
    ]
  })
}

# --- Monitors (Alerts) ---

locals {
  notify_targets = join(" ", var.notification_targets)
}

resource "datadog_monitor" "service_down" {
  count = var.enable ? 1 : 0

  name    = "[Workshop] Service Down - /health non-200"
  type    = "query alert"
  message = "Service ${var.service_name} health endpoint is returning errors. ${local.notify_targets}"

  query = "sum(last_2m):sum:trace.http.server.request.hits{service:${var.service_name},http.status_code:200}.as_count() < 1"

  monitor_thresholds {
    critical = 1
  }

  notify_no_data    = true
  no_data_timeframe = 5

  tags = ["service:${var.service_name}", "team:workshop"]
}

resource "datadog_monitor" "error_rate_spike" {
  count = var.enable ? 1 : 0

  name    = "[Workshop] 5xx Spike - Error rate > 5%"
  type    = "metric alert"
  message = "High 5xx error rate detected for ${var.service_name}. ${local.notify_targets}"

  query = "avg(last_5m):( sum:trace.http.server.request.errors{service:${var.service_name}}.as_count() / sum:trace.http.server.request.hits{service:${var.service_name}}.as_count() ) * 100 > 5"

  monitor_thresholds {
    critical = 5
    warning  = 2
  }

  tags = ["service:${var.service_name}", "team:workshop"]
}

resource "datadog_monitor" "auth_failures" {
  count = var.enable ? 1 : 0

  name    = "[Workshop] Auth Failures Spike"
  type    = "metric alert"
  message = "High number of authentication failures detected. ${local.notify_targets}"

  query = "sum(last_5m):sum:workshop_app_auth_failures_total{*}.as_count() > 50"

  monitor_thresholds {
    critical = 50
    warning  = 20
  }

  tags = ["service:${var.service_name}", "team:workshop"]
}

resource "datadog_monitor" "os_processing_failure" {
  count = var.enable ? 1 : 0

  name    = "[Workshop] Work Order Processing Failures"
  type    = "metric alert"
  message = "Repeated integration errors in order processing. ${local.notify_targets}"

  query = "sum(last_5m):sum:workshop_app_integration_errors_total{*}.as_count() > 10"

  monitor_thresholds {
    critical = 10
    warning  = 5
  }

  tags = ["service:${var.service_name}", "team:workshop"]
}

resource "datadog_monitor" "cpu_saturation" {
  count = var.enable ? 1 : 0

  name    = "[Workshop] CPU Saturation > 80%"
  type    = "metric alert"
  message = "Pod CPU usage is above 80% for 5 minutes. ${local.notify_targets}"

  query = "avg(last_5m):avg:kubernetes.cpu.usage.total{kube_namespace:stag OR kube_namespace:prod} by {pod_name} / avg:kubernetes.cpu.limits{kube_namespace:stag OR kube_namespace:prod} by {pod_name} * 100 > 80"

  monitor_thresholds {
    critical = 80
    warning  = 70
  }

  tags = ["team:workshop"]
}

resource "datadog_monitor" "memory_saturation" {
  count = var.enable ? 1 : 0

  name    = "[Workshop] Memory Saturation > 85%"
  type    = "metric alert"
  message = "Pod memory usage is above 85% for 5 minutes. ${local.notify_targets}"

  query = "avg(last_5m):avg:kubernetes.memory.usage{kube_namespace:stag OR kube_namespace:prod} by {pod_name} / avg:kubernetes.memory.limits{kube_namespace:stag OR kube_namespace:prod} by {pod_name} * 100 > 85"

  monitor_thresholds {
    critical = 85
    warning  = 75
  }

  tags = ["team:workshop"]
}
