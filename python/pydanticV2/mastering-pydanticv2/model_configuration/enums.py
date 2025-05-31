from enum import Enum

from pydantic import BaseModel, ConfigDict, ValidationError

class Color(Enum):
    red = "Red"
    green = "Green"
    blue = "Blue"
    orange = "Orange"
    yellow = "Yellow"
    cyan = "Cyan"
    white = "White"
    black = "Black"

class Model(BaseModel):
    color: Color

Color.red
# <Color.red: 'Red'>

Color.orange.value
# 'Orange'

Model(color=Color.red)
# Model(color=<Color.red: 'Red'>)

data = """
{
    "color": "Red"
}
"""

Model.model_validate_json(data)
# Model(color=<Color.red: 'Red'>)

data = """
{
    "color": "Magenta"
}
"""

try:
    Model.model_validate_json(data)
except ValidationError as ex:
    print(ex)

data = """
{
    "color": "Red"
}
"""

m = Model.model_validate_json(data)

m.model_dump()
# {'color': <Color.red: 'Red'>}

m.model_dump_json()
# '{"color":"Red"}'

class Model(BaseModel):
    model_config = ConfigDict(use_enum_values=True)

    color: Color

m = Model(color=Color.cyan)

m.color
# 'Cyan'

type(m.color)
# str

m.model_dump()
# {'color': 'Cyan'}

data = """
{
    "color": "Magenta"
}
"""

try:
    Model.model_validate_json(data)
except ValidationError as ex:
    print(ex)