import boto3
import os
import json
import mysql.connector as mysql

from utils.Student import Student
from utils.Course import Course

from utils.courses_utils.utils import add_course_to_db, update_course_record

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
    # student page + headers
    type = event['type']
    cursor = db.cursor()
    if type == 'get_all_courses':
        return {'statusCode': 200, 'body': Course(cursor).get_all()}
    elif type == 'search':
        return {'statusCode': 200, 'body': Course(cursor).search(event.get('keyword'), event.get('sort_by'))}
    elif type == 'add':
        course = {'code': event['code'], 'name': event['name'], 'college': event['college']}
        add_course_to_db(cursor, course)
        db.commit()
        return {'statusCode': 200, 'body': course}
    elif type == 'update':
        course = {'code': event['code'], 'name': event['name'], 'college': event['college']}
        update_course_record(cursor, course)
        db.commit()
        return {'statusCode': 200, 'body': course}
    elif type == 'delete':
        Course().delete(cursor, event['code'])
        db.commit()
        return {'statusCode': 200, 'body': 'The records were deleted successfully'}
    cursor.close()
    return {'statusCode': 404, 'body': 'No function were found in used type.'}


# print(lambda_handler({'type': 'search', 'keyword': 'Andrzej', 'sort_by': 'firstname'}, 1))
# print(lambda_handler({'type': 'get_all_courses'}, 1))
# print(lambda_handler({
#     'type': 'add', 'code': 'UJ', 'name': 'Uniwersytet Jagiellonski',
#     'college': 'Agh'}, 2))
# print(lambda_handler({
#     'type': 'update', 'code': 'UJ', 'name': 'Uniwersytet Agiellonski',
#     'college': 'Agh'}, 2))