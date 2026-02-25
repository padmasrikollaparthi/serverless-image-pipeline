variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "uploads_bucket" {
  default = "secure-event-uploads"
}

variable "processed_bucket" {
  default = "secure-event-processed"
}

