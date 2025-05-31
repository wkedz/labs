from pydantic import BaseModel

class Circle(BaseModel):
    center: tuple[int, int] = (0, 0)
    radius: int

Circle.model_fields

# {'center': FieldInfo(annotation=tuple[int, int], required=False, default=(0, 0)),
#  'radius': FieldInfo(annotation=int, required=True)}

# Pydantic will not validate default values
# class Circle(BaseModel):
#     center: tuple[int, int] = "jnk"
#     radius: int
