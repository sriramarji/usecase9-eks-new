# CloudWatch Log Group for Patient Service
resource "aws_cloudwatch_log_group" "patient_service" {
  name              = "/ecs/${var.name}-patient-Log"
  retention_in_days = 7
}

# CloudWatch Log Group for Appointment Service
resource "aws_cloudwatch_log_group" "appointment_service" {
  name              = "/ecs/${var.name}-appointment-log"
  retention_in_days = 7
}

#resource "aws_cloudwatch_log_stream" "ecs_log_stream" {
#  log_group_name = aws_cloudwatch_log_group.ecs_log_group.name
#  name           = "${var.name}-stream"
#}


output "patient_service_log_group_name" {
  description = "The name of the CloudWatch log group for the patient service"
  value       = aws_cloudwatch_log_group.patient_service.name
}

output "appointment_service_log_group_name" {
  description = "The name of the CloudWatch log group for the appointment service"
  value       = aws_cloudwatch_log_group.appointment_service.name
}
