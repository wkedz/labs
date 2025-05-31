# By default pydantic will not validate assignments to the created model.

from pydantic import BaseModel, ConfigDict, ValidationError

class Model(BaseModel):
    field: int

m = Model(field=10)
m.field = "Python" # This is ok

# In order to validate assigment we need to change model_config

class ModelWithValidation(BaseModel):
    model_config = ConfigDict(validate_assignment=True)

    field: int
m_with_validation = ModelWithValidation(field=10)
try:
    m_with_validation.field = "Python"  # This will raise an error
except ValidationError as ex:
    print("\nModelWithValidation")
    print(ex)