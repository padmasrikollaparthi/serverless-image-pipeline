terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "functions_sa" {
  account_id   = "serverless-pipeline-sa"
  display_name = "Serverless Pipeline SA"
}

resource "google_project_iam_member" "gcs" {
  project = var.project_id
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.functions_sa.email}"
}

resource "google_project_iam_member" "pubsub" {
  project = var.project_id
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.functions_sa.email}"
}

resource "google_project_iam_member" "pubsub_sub" {
  project = var.project_id
  role   = "roles/pubsub.subscriber"
  member = "serviceAccount:${google_service_account.functions_sa.email}"
}

resource "google_project_iam_member" "logging" {
  project = var.project_id
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.functions_sa.email}"
}

resource "google_project_iam_member" "secret" {
  project = var.project_id
  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.functions_sa.email}"
}

resource "google_storage_bucket" "uploads" {
  name     = "${var.project_id}-${var.uploads_bucket}"
  location = var.region
   
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket" "processed" {
  name     = "${var.project_id}-${var.processed_bucket}"
  location = var.region

  uniform_bucket_level_access = true
}

resource "google_pubsub_topic" "requests" {
  name = "image-processing-requests"
}

resource "google_pubsub_topic" "results" {
  name = "image-processing-results"
}

resource "google_secret_manager_secret" "api_key" {
  secret_id = "api-gateway-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "api_key_version" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = "CHANGE-ME-API-KEY"
}

resource "google_cloudfunctions2_function" "upload" {
  name     = "upload-image"
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = "upload_image"
    source {
      storage_source {
        bucket = google_storage_bucket.uploads.name
        object = "upload.zip"
      }
    }
  }

  service_config {
    service_account_email = google_service_account.functions_sa.email
    environment_variables = {
      UPLOAD_BUCKET = google_storage_bucket.uploads.name
      TOPIC_NAME    = google_pubsub_topic.requests.name
    }
  }
}
resource "google_cloudfunctions2_function" "process" {
  name     = "process-image"
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = "process_image"
    source {
      storage_source {
        bucket = google_storage_bucket.uploads.name
        object = "process-function-source.zip"
      }
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.storage.object.v1.finalized"

    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.uploads.name
    }
  }

  service_config {
    service_account_email = google_service_account.functions_sa.email
  }
}

