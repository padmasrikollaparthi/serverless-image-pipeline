import base64
import json
import logging

def log_notification(event, context):
    try:
        message = base64.b64decode(event['data']).decode('utf-8')
        data = json.loads(message)

        logging.info(json.dumps({
            "status": "SUCCESS",
            "original_file": data.get("original_file"),
            "processed_file": data.get("processed_file"),
            "bucket": data.get("bucket")
        }))

        return "Logged successfully"

    except Exception as e:
        logging.error(f"Failed to log notification: {str(e)}")
        return "Error"

