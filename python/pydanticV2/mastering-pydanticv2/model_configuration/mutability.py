# In order to prevent modyfing the model after creation we can use `frozen=True` in the model config.
from pydantic import BaseModel, ConfigDict

class ModelFrozen(BaseModel):
    model_config = ConfigDict(frozen=True)

    field: int

m = ModelFrozen(field=10)
try:
    m.field=20
except ValidationError as ex:
    print(ex)

# This can be usefull, when we want model to be a key in dictonary
# Key of dictionary cannot be mutable. 

class ModelNoFrozen(BaseModel):
    model_config = ConfigDict(frozen=False)

    field: int


m = ModelNoFrozen(field=10)
try:
    d = {m: "not gonna work!"}
except TypeError as ex:
    print(ex)