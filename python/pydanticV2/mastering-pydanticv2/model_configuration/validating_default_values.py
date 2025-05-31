from pydantic import BaseModel, ConfigDict, ValidationError


# By default pydantic will not validate default values, so if you set a default value that is not valid, it will not raise an error.
class Model(BaseModel):
    field_1: int = None
    field_2: str = 100

# But it will raise an error if you try to set a value that is not valid.

Model() # this is ok

try: 
    Model(field_1="string")  # this will raise an error
except ValidationError as ex:
    print("\nModel")
    print(ex)

# We can change this behavior by setting the `validate_default` option in the model's config.
class ModelWithValidation(BaseModel):
    model_config = ConfigDict(validate_default=True)

    field_1: int = None
    field_2: str = 100
try:
    ModelWithValidation()  # this will raise an error because field_1 is None
except ValidationError as ex:
    print("\nModelWithValidation")
    print(ex)