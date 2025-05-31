# https://docs.pydantic.dev/latest/api/config/#pydantic.config.ConfigDict.extra

# We can pass extra fields to the model, but we need to configure the model to allow it.
# In order to do that we need to set the `extra` attribute in the model's config.

# From the documentation we see that this `extra` option can be set to one of three possible values:
# - `ignore` - the default behavior
# - `forbid` - this will cause a validation error is extra fields are encountered in the data
# - `allow` - this will actually add the field and it's value to the model, but of course without any validation.

from pydantic import BaseModel, ConfigDict, ValidationError

class Model(BaseModel):
    # We could use here simple dict, but this is not recommended, because ConfigDict is typed checked
    model_config = ConfigDict(extra="ignore")

    field_1: int = 0

m = Model(field_1=10, extra_1="data") # OK

class Model2(BaseModel):
    model_config = ConfigDict(extra="forbid")

    field_1: int = 0

try:
    Model2(field_1=10, extra_1="data")
except ValidationError as ex:
    print(ex)

## Visibility 
m.model_fields
# {'field_1': FieldInfo(annotation=int, required=False, default=0)}

m.model_dump()
# {'field_1': 10, 'extra_1': 'data'}

m.model_fields_set
# {'extra_1', 'field_1'}

m.model_extra
# {'extra_1': 'data'}

## Checking config 
Model.model_config
m.model_config
# {'extra': 'allow'}