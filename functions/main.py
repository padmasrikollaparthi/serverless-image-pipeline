import json, logging

def log_notification(event, context):
    data = json.loads(event['data'])
    logging.info(json.dumps({
        "status": "processed",
        "file": data["file"]
    }))

