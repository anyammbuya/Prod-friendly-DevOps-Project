variable "deletion_days" {
  type        = string
  description = "Default pending deletion days"
  default     = "7"
}

variable "tags" {
  description = "tags"
}

variable "policy" {
  description = "The KMS key policy document."
  type        = any
}