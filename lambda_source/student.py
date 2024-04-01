import boto3
import os
import json
import mysql.connector as mysql

from utils.Student import Student
from utils.Course import Course

from utils.student_utils.utils import add_student_to_db, update_student_record

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
    if type == 'get_all_students':
        return {'statusCode': 200, 'body': Student(cursor).get_all()}
    elif type == 'search':
        return {'statusCode': 200, 'body': Student(cursor).search(event.get('keyword'), event.get('sort_by'))}
    elif type == 'add':
        student = {'id': event['id'], 'firstname': event['firstName'], 'middlename': event['middleName'],
            'lastname': event['lastName'], 'yearlevel': event['yearLevel'], 'gender': event['gender'],
            'course': event['course']}
        add_student_to_db(student, cursor)
        db.commit()
        return {'statusCode': 200, 'body': student}
    elif type == 'update':
        student = {'id': event['id'], 'firstname': event['firstName'], 'middlename': event['middleName'],
            'lastname': event['lastName'], 'yearlevel': event['yearLevel'], 'gender': event['gender'],
            'course': event['course']}
        update_student_record(cursor, student)
        db.commit()
        return {'statusCode': 200, 'body': student}
    elif type == 'delete':
        Student().delete(cursor, event['id'])
        db.commit()
        return {'statusCode': 200, 'body': 'The records were deleted successfully'}
    cursor.close()
    return {'statusCode': 404, 'body': 'No function were found in used type.'}