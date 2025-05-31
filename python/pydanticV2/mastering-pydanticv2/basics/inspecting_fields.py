from pydantic import BaseModel

class Circle(BaseModel):
    center_x: int = 0
    center_y: int = 0
    radius: int = 1
    name: str | None = None

c1 = Circle(radius=2)
c1.model_dump()
# {'center_x': 0, 'center_y': 0, 'radius': 2, 'name': None}

# Show only variables that were set
c1.model_fields_set
{'radius'}

# We can make operations on it
c1.model_fields.keys() - c1.model_fields_set
# {'center_x', 'center_y', 'name'}


class Model(BaseModel):
    field_1: int = 1
    field_2: int | None = None
    field_3: str 
    field_4: str | None = "Python"


m1 = Model(field_3="m1")
m1.model_dump(include=m1.model_fields_set)    
# {'field_3': 'm1'}
