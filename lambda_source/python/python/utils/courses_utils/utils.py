from ..College import College
from ..Course import Course

def add_course_to_db(cursor, course: str = None) -> bool:
    code = (course['code'].strip()).upper()
    name = (course['name'].strip()).title()
    college = College().get_collegecode_for(cursor, course['college'])
    # code validation
    if code and code not in Course().get_coursecodes(cursor):
        # name validation
        if name:
            Course(
                cursor,
                code,
                name,
                college
            ).add_new()
            return None
    return False


#HERE
def update_course_record(cursor, course: str = None) -> bool:
    code = course['code']
    name = course['name'].strip()
    college = course['college']
    
    if code and name:
        Course(
            cursor,
            code,
            name,
            College().get_collegecode_for(cursor, college)
        ).update()
        return None
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