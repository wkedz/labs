from pydantic import BaseModel, ValidationError

class Person(BaseModel):
    first_name: str
    last_name: str
    age: int

galois = Person(first_name='Evariste', last_name='Galois', age=20)
newton = Person(first_name='Isaac', last_name='Newton', age=84)

# simple dict displaying 
newton.__dict__

# pytdantic has special metods that allow to dumping with some modifications
# model_dump()
# model_dump_json()

# dump to dict
galois.model_dump()

# dump to json
galois.model_dump_json()

#Note that under the hood, Pydantic uses `dumps()` from the `json` module - which means you can technically pass arguments to it via the `model_dump_json()` method.
newton.model_dump_json(indent=2)
print(newton.model_dump_json(indent=2))
galois.model_dump(exclude=['first_name', 'age'])
# {'last_name': 'Galois'}

# We can also explicit set what to include
newton.model_dump(include=["last_name"])
# {'last_name': 'Newton'}
