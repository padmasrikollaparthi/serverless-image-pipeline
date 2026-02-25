import os
from google.cloud import storage, pubsub_v1
from PIL import Image
import io

def process_image(event, context):
    """
    Triggered by a file upload to GCS.
    Converts images to grayscale and uploads to processed bucket.
    Publishes the result to Pub/Sub.
    """
    bucket_name = event['bucket']
    file_name = event['name']

    print(f"Processing file: {file_name} from bucket: {bucket_name}")

    # Only process image files (png, jpg, jpeg)
    if not file_name.lower().endswith((".png", ".jpg", ".jpeg")):
        print(f"Skipped non-image file: {file_name}")
        return

    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    img_bytes = blob.download_as_bytes()

    img = Image.open(io.BytesIO(img_bytes)).convert("L")

    # Upload processed image
    processed_bucket_name = os.environ.get(
        "PROCESSED_BUCKET", "serverless-pipeline-488416-secure-event-processed"
    )
    out_bucket = client.bucket(processed_bucket_name)
    out_blob = out_bucket.blob(file_name)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    out_blob.upload_from_string(buf.getvalue())

    print(f"Uploaded processed image to: {processed_bucket_name}/{file_name}")

    # Publish to Pub/Sub
    publisher = pubsub_v1.PublisherClient()
    project_id = os.environ.get("GCP_PROJECT", "serverless-pipeline-488416")
    topic_name = os.environ.get("RESULT_TOPIC", "image-processing-results")
    topic_path = publisher.topic_path(project_id, topic_name)
    publisher.publish(topic_path, f'{{"file": "{file_name}"}}'.encode())

    print(f"Published message to Pub/Sub: {topic_name}")

