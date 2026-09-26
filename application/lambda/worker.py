import json


def lambda_handler(event, context):
    for record in event["Records"]:
        body = json.loads(record["body"])

        print("ORDER EVENT:")
        print(json.dumps(body, indent=2))

    return {
        "statusCode": 200
    }