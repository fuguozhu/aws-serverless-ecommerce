import json
import os
import uuid
from datetime import datetime, timezone
from decimal import Decimal

import boto3
from botocore.exceptions import ClientError


dynamodb = boto3.resource("dynamodb")
events = boto3.client("events")

products_table = dynamodb.Table(os.environ["PRODUCTS_TABLE"])
orders_table = dynamodb.Table(os.environ["ORDERS_TABLE"])


def decimal_to_int(obj):
    if isinstance(obj, Decimal):
        return int(obj)
    raise TypeError(f"Object of type {type(obj).__name__} is not JSON serializable")


def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body, default=decimal_to_int)
    }


def get_products(event, context):
    result = products_table.scan()
    return response(200, result["Items"])


def create_order(event, context):
    try:
        body = json.loads(event.get("body", "{}"))

        product_id = body["productId"]
        quantity = int(body["quantity"])

        if quantity <= 0:
            return response(400, {
                "message": "quantity must be greater than 0"
            })

        claims = event["requestContext"]["authorizer"]["claims"]
        user_id = claims["sub"]

        product = products_table.get_item(
            Key={
                "productId": product_id
            }
        ).get("Item")

        if not product:
            return response(404, {
                "message": "Product not found"
            })

        price = product["price"]

        try:
            products_table.update_item(
                Key={
                    "productId": product_id
                },
                UpdateExpression="SET stock = stock - :quantity",
                ConditionExpression="stock >= :quantity",
                ExpressionAttributeValues={
                    ":quantity": quantity
                }
            )
        except ClientError as error:
            if error.response["Error"]["Code"] == "ConditionalCheckFailedException":
                return response(409, {
                    "message": "Insufficient stock"
                })
            raise

        order_id = str(uuid.uuid4())

        order = {
            "orderId": order_id,
            "userId": user_id,
            "productId": product_id,
            "quantity": quantity,
            "price": price,
            "status": "CREATED",
            "createdAt": datetime.now(timezone.utc).isoformat()
        }

        orders_table.put_item(
            Item=order
        )

        event_detail = {
            "eventType": "OrderCreated",
            "order": order
        }

        events.put_events(
            Entries=[
                {
                    "EventBusName": os.environ["ORDER_EVENT_BUS_NAME"],
                    "Source": "serverless-ecommerce",
                    "DetailType": "OrderCreated",
                    "Detail": json.dumps(event_detail, default=decimal_to_int)
                }
            ]
        )

        return response(201, order)

    except KeyError as error:
        return response(400, {
            "message": f"Missing field: {error.args[0]}"
        })

    except ValueError:
        return response(400, {
            "message": "quantity must be an integer"
        })

    except Exception as error:
        print(f"Unexpected error: {error}")

        return response(500, {
            "message": "Internal server error"
        })


def lambda_handler(event, context):
    print("EVENT:", json.dumps(event))

    route_key = event.get("routeKey")

    if route_key == "GET /products":
        return get_products(event, context)

    if route_key == "POST /orders":
        return create_order(event, context)

    request_context = event.get("requestContext", {})

    method = request_context.get("httpMethod")
    path = request_context.get("path")

    if method == "GET" and path == "/products":
        return get_products(event, context)

    if method == "POST" and path == "/orders":
        return create_order(event, context)

    print("Unknown route:", route_key, method, path)

    return response(404, {
        "message": "Route not found"
    })
