# We can modifie string by using ConfigDict
from pydantic import BaseModel, ConfigDict

class Model(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    field: str

m1 = Model(field="   python")
m2 = Model(field="  python   \t")
# in both "python"
m1 == m2

class ModelLower(BaseModel):
    model_config=ConfigDict(str_to_lower=True)

    field: str

m = ModelLower(field="PYTHON")
m    

class Model(BaseModel):
    model_config=ConfigDict(str_to_upper=True)

    field: str

m = Model(field="Python")
m    