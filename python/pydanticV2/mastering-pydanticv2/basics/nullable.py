# Nullability of a field has nothing to do with whether it is optional or not - it basically just indicates whether a field can be set to `None` (or `null` in JSON) perspective.

## Required, Not Nullable
class Model(BaseModel):
    field: int


## Required, Nullable
class Model(BaseModel):
    field: int | None


## Optional, Not Nullable
class Model(BaseModel):
    field: int = 0


## Optional, Nullable
class Model(BaseModel):
    field: int | None = None