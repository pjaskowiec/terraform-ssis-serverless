import boto3
import os
import json
import mysql.connector as mysql

from utils.College import College
from utils.Course import Course

from utils.college_utils.utils import add_college_to_db, update_college_record

secrets_manager = boto3.client('secretsmanager', region_name="eu-north-1")
secret_name = "student-app/db-local-creds"

def get_db_credentials():
    response = secrets_manager.get_secret_value(SecretId=secret_name)
    secret = response['SecretString']
    return json.loads(secret)


def connect_to_database():
    credentials = get_db_credentials()
    db = mysql.connect(
            host = credentials["host"],
            user = credentials["username"],
            password = credentials["password"],
            database = credentials["dbname"]
        )
    return db


db = connect_to_database()

def lambda_handler(event, context):
    type = event['type']
    cursor = db.cursor()
    if type == 'get_all_colleges':
        return {'statusCode': 200, 'body': College(cursor).get_all()}
    elif type == 'search':
        return {'statusCode': 200, 'body': College(cursor).search(event.get('keyword'), event.get('sort_by'))}
    elif type == 'add':
        college = {'code': event['code'], 'name': event['name']}
        add_college_to_db(cursor, college)
        db.commit()
        return {'statusCode': 200, 'body': college}
    elif type == 'update':
        college = {'code': event['code'], 'name': event['name']}
        update_college_record(cursor, college)
        db.commit()
        return {'statusCode': 200, 'body': college}
    elif type == 'delete':
        College().delete(cursor, event['code'])
        db.commit()
        return {'statusCode': 200, 'body': 'The records were deleted successfully'}
    cursor.close()
    return {'statusCode': 404, 'body': 'No function were found in used type.'}


# print(lambda_handler({'type': 'search', 'keyword': 'Andrzej', 'sort_by': 'firstname'}, 1))
# print(lambda_handler({'type': 'get_all_colleges'}, 1))
# print(lambda_handler({'type': 'search', 'sort_by': 'code', 'keyword': 'CED'}, 1))
# print(lambda_handler({'type': 'add', 'code': 'UJ', 'name': 'Uniwersytet Jagiellonski'}, 1))
# print(lambda_handler({
#     'type': 'add', 'code': 'UJ', 'name': 'Uniwersytet Jagiellonski',
#     'college': 'Agh'}, 2))
# print(lambda_handler({
#     'type': 'update', 'code': 'UJ', 'name': 'Uniwersytet Agiellonski',
#     'college': 'Agh'}, 2))