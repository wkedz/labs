from pydantic import BaseModel, ConfigDict, ValidationError

# By default we cannot assign numbers to string fields.
class Model(BaseModel):
    field: str

try:
    Model(field=100)
except ValidationError as ex:
    print(ex)

# In order to allow numbers to be coerced to strings we can use `coerce_numbers_to_str=True` in the model config.
class ModelAllow(BaseModel):
    model_config = ConfigDict(coerce_numbers_to_str=True)
    
    field: str

Model(field=100)