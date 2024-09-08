import json
import os
import requests
import datetime
import boto3
import logging
import calendar
import pytz

logger = logging.getLogger()
logger.setLevel(logging.INFO)

WEBHOOK_URL = os.environ.get('WEBHOOK_URL')
NOTIFICATION_SERVICE = os.environ.get('NOTIFICATION_SERVICE', 'discord')
TOKYO_TZ = pytz.timezone('Asia/Tokyo')

def get_today_and_end_of_month():
    today = datetime.datetime.now(TOKYO_TZ)

    start_of_month = datetime.datetime(today.year, today.month, 1)
    end_of_month = datetime.datetime(today.year, today.month, calendar.monthrange(today.year, today.month)[1])

    today_str = today.strftime('%Y-%m-%d')
    start_of_month_str = start_of_month.strftime('%Y-%m-%d')
    end_of_month_str = end_of_month.strftime('%Y-%m-%d')

    return today_str, start_of_month_str, end_of_month_str

def get_forecast_cost(ce_client, start_date, end_date):
    try:
        response = ce_client.get_cost_forecast(
            TimePeriod={
                'Start': start_date,
                'End': end_date
            },
            Metric='UNBLENDED_COST',
            Granularity='MONTHLY'
        )
        return float(response['Total']['Amount'])
    except Exception as e:
        logger.error(f"Failed to get forecast cost: {str(e)}")
        return 0.0

def get_current_cost(client, start_time, end_time):
    try:
        response = client.get_cost_and_usage(
            TimePeriod={
                'Start': start_time,
                'End': end_time
            },
            Granularity='MONTHLY',
            Metrics=["UnblendedCost"]
        )
        results_by_time = response.get('ResultsByTime')
        if results_by_time:
            total_cost = sum(float(day['Total']['UnblendedCost']['Amount']) for day in results_by_time)
        else:
            total_cost = 0
        return total_cost
    except Exception as e:
        logger.error(f"Failed to get current cost: {str(e)}")
        return 0.0

def send_discord_notification(messages):
    headers = {'Content-Type': 'application/json'}
    try:
        response = requests.post(WEBHOOK_URL, data=json.dumps({'content': "\n".join(messages)}), headers=headers)
        return {
            'statusCode': response.status_code,
            'body': response.text
        }
    except requests.RequestException as e:
        logger.error(f"Failed to send Discord notification: {str(e)}")
        return {
            'statusCode': 500,
            'body': f"Failed to send Discord notification: {str(e)}"
        }

def send_slack_notification(messages):
    headers = {'Content-Type': 'application/json'}
    try:
        response = requests.post(WEBHOOK_URL, data=json.dumps({'text': "\n".join(messages)}), headers=headers)
        return {
            'statusCode': response.status_code,
            'body': response.text
        }
    except requests.RequestException as e:
        logger.error(f"Failed to send Slack notification: {str(e)}")
        return {
            'statusCode': 500,
            'body': f"Failed to send Slack notification: {str(e)}"
        }

def send_notification(messages):
    if NOTIFICATION_SERVICE == 'slack':
        return send_slack_notification(messages)
    else:
        return send_discord_notification(messages)

def handler(event, context):
    today, start_of_month, end_of_month = get_today_and_end_of_month()
    ce_client = boto3.client('ce')
    forecast_cost = get_forecast_cost(ce_client, today, end_of_month)
    current_cost = get_current_cost(ce_client, start_of_month, end_of_month)

    messages = [
        f"当月の現費用：${current_cost:.2f}",
        f"当月の予測費用：${forecast_cost:.2f}\n"
    ]

    send_notification(messages)
