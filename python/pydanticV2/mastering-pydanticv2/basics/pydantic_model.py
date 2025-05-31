from pydantic import BaseModel, ValidationError

class Person(BaseModel):
    first_name: str
    last_name: str
    age: int


# Creating simple instance.
p = Person(first_name="Evariste", last_name="Galois", age=20)

# inspecting attributes.
p.model_fields

# Pydantic will autmatically validate inpiuts while creating an instance .

try:
    Person(last_name='Galois')
except ValidationError as ex:
    print(ex)

# But when instance is created  it will not validate the attributes.
p.age = 'twenty'