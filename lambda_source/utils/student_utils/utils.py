from ..Student import Student
from ..Course import Course


def add_student_to_db(student: list, cursor) -> bool:
    id = student['id'].strip()
    firstname = (student['firstname'].strip()).title()
    middlename = (student['middlename'].strip()).title()
    lastname = (student['lastname'].strip()).title()
    gender = student['gender'].strip()
    yearlevel = student['yearlevel']
    course = student['course']
    # ID validation
    if id:
        if id not in Student().get_IDs(cursor):
            # Name validation
            if firstname and lastname:
                Student(
                    cursor=cursor,
                    id=id, 
                    firstName=firstname, 
                    middleName=middlename, 
                    lastName=lastname,
                    yearLevel=yearlevel,
                    gender=gender,  
                    course=Course().get_coursecode_for(cursor, course),
                    college=Course().get_collegecode(cursor, course),
                ).add_new()
                return True
            return False
        return False


def update_student_record(cursor, student: list = None) -> bool:
    id = student['id'].strip()
    firstname = student['firstname'].strip()
    middlename = student['middlename'].strip()
    lastname = student['lastname'].strip()
    gender = student['gender'].strip()
    yearlevel = student['yearlevel']
    course = student['course']
    
    if firstname and lastname:
        Student(
            cursor=cursor,
            id=id, 
            firstName=firstname,
            middleName=middlename, 
            lastName=lastname,
            yearLevel=yearlevel,
            gender=gender, 
            course=Course().get_coursecode_for(cursor, course),
            college=Course().get_collegecode(cursor, course)
        ).update()
        return None
    else:
        return False


def check_page_limit(min: bool = None, max: bool = None) -> str:
    if min:
        return 'min'
    elif max:
        return 'max'
    else:
        return


def check_limit_validity(number_input: int = None, max_limit: int = None) -> int:
    if number_input < 5:
        return 5
    elif number_input > max_limit:
        return max_limit
    else:
        
        return number_input