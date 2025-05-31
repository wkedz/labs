from pydantic import BaseModel, ValidationError

class Person(BaseModel):
    first_name: str
    last_name: str
    age: int

data = {
    "first_name": "Isaac",
    "last_name": "Newton",
    "age": 84
}

# Available, but not recommended way to create an instance.
Person(**data)

# this will validate data.
p = Person.model_validate(data)

missing_data = {"last_name": "Newton"}

try:
    Person.model_validate(missing_data)
except ValidationError as ex:
    print(ex)

# Validating json
data_json = '''
{
    "first_name": "Isaac",
    "last_name": "Newton",
    "age": 84
}
'''
p = Person.model_validate_json(data_json)

missing_data_json = '''
{
    "last_name": "Newton"
}
'''

try:
    Person.model_validate_json(missing_data_json)
except ValidationError as ex:
    print(ex)