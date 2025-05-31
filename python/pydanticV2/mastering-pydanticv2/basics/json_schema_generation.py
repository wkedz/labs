# https://docs.pydantic.dev/latest/api/json_schema/
# https://docs.pydantic.dev/latest/api/base_model/#pydantic.BaseModel.__init__

from pydantic import BaseModel

class Model(BaseModel):
    field_1: int | None = None
    field_2: str = "Python"

from pprint import pprint

pprint(Model.model_json_schema())    

# {'properties': {'field_1': {'anyOf': [{'type': 'integer'}, {'type': 'null'}],
#                             'default': None,
#                             'title': 'Field 1'},
#                 'field_2': {'default': 'Python',
#                             'title': 'Field 2',
#                             'type': 'string'}},
#  'title': 'Model',
#  'type': 'object'}