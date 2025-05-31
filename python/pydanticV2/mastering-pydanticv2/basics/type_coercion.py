# Pydantic docs that describes what type coercions will be attempted in either of these modes, is located here:
# [https://docs.pydantic.dev/latest/concepts/conversion_table/](https://docs.pydantic.dev/latest/concepts/conversion_table/)

from pydantic import BaseModel, ValidationError

class Coordinates(BaseModel):
    x: float
    y: float

p1 = Coordinates(x=1.1, y=2.2)

# Pydantic will attempt to "transform" the data into the correct type - this is called type **coercion**
p2 = Coordinates(x=0, y="1.2")

# Pydantic has few levels of coercion, and the default is to be permissive.
# If you want to be more strict, you can set `model_config` to `strict=True`
p3 = Coordinates.model_validate({"x": "1.1", "y": 2.2})
try:
    p4 = Coordinates.model_validate({"x": "not a number", "y": 2.2}, strict=True)
except ValidationError as e:
    print("Validation error:", e)