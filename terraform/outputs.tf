output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "uploads_bucket" {
  value = google_storage_bucket.uploads.name
}

output "processed_bucket" {
  value = google_storage_bucket.processed.name
}

output "service_account" {
  value = google_service_account.functions_sa.email
}

output "requests_topic" {
  value = google_pubsub_topic.requests.name
}

output "results_topic" {
  value = google_pubsub_topic.results.name
}

output "api_key_secret_name" {
  value = google_secret_manager_secret.api_key.name
}

