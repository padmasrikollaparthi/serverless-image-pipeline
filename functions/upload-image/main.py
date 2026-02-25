import os, uuid, json
from flask import Request
from google.cloud import storage, pubsub_v1

def upload_image(request: Request):
    file = request.files['file']
    bucket_name = os.environ["UPLOAD_BUCKET"]
    topic_name = os.environ["TOPIC_NAME"]

    client = storage.Client()
    bucket = client.bucket(bucket_name)

    filename = f"{uuid.uuid4()}-{file.filename}"
    blob = bucket.blob(filename)
    blob.upload_from_file(file)

    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(os.environ["GCP_PROJECT"], topic_name)

    publisher.publish(topic_path, json.dumps({
        "bucket": bucket_name,
        "name": filename
    }).encode())

    return {"id": filename}, 202

