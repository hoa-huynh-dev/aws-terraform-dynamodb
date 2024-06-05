locals {
  table_name = "${var.table_prefix}-${var.table_name}"

  enable_autoscale_capacity     = upper(var.billing_mode) == "PROVISIONED" ? true : false
  autosacale_read_capacity_min  = var.autoscale_capacity != null ? var.autoscale_capacity.read.min_capacity : var.read_capacity
  autosacale_read_capacity_max  = var.autoscale_capacity != null ? var.autoscale_capacity.read.max_capacity : var.read_capacity
  autosacale_read_target_value  = var.autoscale_capacity != null ? var.autoscale_capacity.read.target_value : 70
  autosacale_write_capacity_min = var.autoscale_capacity != null ? var.autoscale_capacity.wrtie.min_capacity : var.write_capacity
  autosacale_write_capacity_max = var.autoscale_capacity != null ? var.autoscale_capacity.write.max_capacity : var.write_capacity
  autosacale_write_target_value = var.autoscale_capacity != null ? var.autoscale_capacity.write.target_value : 70
}

resource "aws_dynamodb_table" "table" {
  name           = local.table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  range_key      = var.range_key

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  global_secondary_index {
    name            = var.gsi_name
    hash_key        = var.gsi_hash_key
    range_key       = var.gsi_range_key
    projection_type = "ALL"
    read_capacity   = var.gsi_read_capacity
    write_capacity  = var.gsi_write_capacity
  }
}

resource "aws_appautoscaling_target" "table_read_target" {
  count              = local.enable_autoscale_capacity ? 1 : 0
  min_capacity       = local.autosacale_read_capacity_min
  max_capacity       = local.autosacale_read_capacity_max
  resource_id        = "table/${local.table_name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_target" "table_write_target" {
  count              = local.enable_autoscale_capacity ? 1 : 0
  min_capacity       = local.autosacale_write_capacity_min
  max_capacity       = local.autosacale_write_capacity_max
  resource_id        = "table/${local.table_name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "table_read_capacity_scaling_policy" {
  count              = local.enable_autoscale_capacity ? 1 : 0
  name               = "${local.table_name}-read-capacity-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = local.autosacale_read_target_value
  }
}

resource "aws_appautoscaling_policy" "table_write_capacity_scaling_policy" {
  count              = local.enable_autoscale_capacity ? 1 : 0
  name               = "${local.table_name}-write-capacity-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = local.autosacale_write_target_value
  }
}
