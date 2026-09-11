resource "sakura_auto_scale" "web_servers" {
  name        = "${var.prefix}-autoscale"
  description = "Auto Scale group for web servers"

  zones = [var.zone]
  config = jsonencode({
    resources = [{
      type = "Server"
      selector = {
        names = [sakura_server.initial.name]
        zones = [var.zone]
      }
    }]
  })

  trigger_type = "cpu"

  cpu_threshold_scaling = {
    server_prefix = "${var.prefix}-initial"
    up            = var.cpu_threshold_up
    down          = var.cpu_threshold_down
  }

  schedule_scaling = [{
    action       = "up"
    hour         = var.scale_up_hour
    minute       = var.scale_up_minute
    days_of_week = ["mon", "tue", "wed", "thu", "fri"]
  },
  {
    action       = "down"
    hour         = var.scale_down_hour
    minute       = var.scale_down_minute
    days_of_week = ["mon", "tue", "wed", "thu", "fri"]
  }]

  api_key_id = var.api_key_id

}

# Load balancer configuration commented out due to API changes
# resource "sakura_dsr_lb" "main" {
#   name           = "${var.prefix}-lb"
#   description    = "Load Balancer for Auto Scale"
#   plan           = var.elb_plan
# }