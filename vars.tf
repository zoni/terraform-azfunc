variable "LOCATION" {}
variable "PROJECT_NAME" {}
variable "RESOURCE_GROUP_NAME" {}
variable "CUSTOM_DOMAIN" {}
variable "FUNCTIONS_WORKER_RUNTIME" {
  default = "node"
}
variable "TAGS" {
  default = {}
}
variable "EXTRA_APP_SETTINGS" {
  default = {}
}

variable "APP_INSIGHTS_APPLICATION_TYPE" {
  default = "other"
}
variable "APP_INSIGHTS_RETENTION_DAYS" {
  default = "90"
}
variable "APP_INSIGHTS_SAMPLING_PERCENTAGE" {
  default = "100"
}
variable "APP_INSIGHTS_DISABLE_IP_MASKING" {
  default = false
}
