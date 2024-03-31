from ..College import College


def add_college_to_db(cursor, college: str = None) -> bool:
    code = (college['code'].strip()).upper()
    name = (college['name'].strip()).title()
    # code validation
    if code and code not in College().get_collegecodes(cursor):
        # name validation
        if name:
            College(
                cursor,
                code,
                name
            ).add_new()
            return None
    return False


def update_college_record(cursor, college: str = None) -> bool:
    code = college['code']
    name = college['name'].strip()
    
    if name:
        College(
            cursor,
            code,
            name
        ).update()
        return None
    else:
        return False