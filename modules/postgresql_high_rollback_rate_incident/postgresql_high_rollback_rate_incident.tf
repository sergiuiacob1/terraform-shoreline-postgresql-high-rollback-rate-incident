resource "shoreline_notebook" "postgresql_high_rollback_rate_incident" {
  name       = "postgresql_high_rollback_rate_incident"
  data       = file("${path.module}/data/postgresql_high_rollback_rate_incident.json")
  depends_on = [shoreline_action.invoke_calculate_rollback_rate,shoreline_action.invoke_optimize_database_config]
}

resource "shoreline_file" "calculate_rollback_rate" {
  name             = "calculate_rollback_rate"
  input_file       = "${path.module}/data/calculate_rollback_rate.sh"
  md5              = filemd5("${path.module}/data/calculate_rollback_rate.sh")
  description      = "Measure the rollback rate"
  destination_path = "/agent/scripts/calculate_rollback_rate.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "optimize_database_config" {
  name             = "optimize_database_config"
  input_file       = "${path.module}/data/optimize_database_config.sh"
  md5              = filemd5("${path.module}/data/optimize_database_config.sh")
  description      = "Optimize the database configuration to reduce the frequency of rollbacks. Adjusting the database settings can help to optimize the rollback rate."
  destination_path = "/agent/scripts/optimize_database_config.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_calculate_rollback_rate" {
  name        = "invoke_calculate_rollback_rate"
  description = "Measure the rollback rate"
  command     = "`/agent/scripts/calculate_rollback_rate.sh`"
  params      = []
  file_deps   = ["calculate_rollback_rate"]
  enabled     = true
  depends_on  = [shoreline_file.calculate_rollback_rate]
}

resource "shoreline_action" "invoke_optimize_database_config" {
  name        = "invoke_optimize_database_config"
  description = "Optimize the database configuration to reduce the frequency of rollbacks. Adjusting the database settings can help to optimize the rollback rate."
  command     = "`/agent/scripts/optimize_database_config.sh`"
  params      = ["DATABASE_PORT","DATABASE_NAME","DATABASE_PASSWORD","DATABASE_HOST"]
  file_deps   = ["optimize_database_config"]
  enabled     = true
  depends_on  = [shoreline_file.optimize_database_config]
}

