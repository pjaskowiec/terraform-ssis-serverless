import boto3
import os
import json
import mysql.connector as mysql

from werkzeug.security import check_password_hash

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


def registered_user(username, password):
    db = connect_to_database()
    query = f'''
        SELECT username, password 
        FROM admin
        WHERE username = '{username}';
    '''
    c = db.cursor()
    c.execute(query)
    user = c.fetchone()
    c.close()
    if user is not None:
        password_sha = user[1]
        if check_password_hash(password_sha, password):
            return True
    return False


def lambda_handler(event, context):
    # Extract username and password from event
    username = event['username']
    password = event['password']
    if registered_user(username, password):
        return {'statusCode': 200, 'body': 'User authenticated successfully'}
    return {'statusCode': 401, 'body': 'Unauthorized'}