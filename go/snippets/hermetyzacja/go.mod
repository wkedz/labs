module hermetyzacja

go 1.20

replace outsidestruct => ./outsidestruct

replace insidestruct => ./insidestruct

require (
	insidestruct v0.0.0-00010101000000-000000000000
	outsidestruct v0.0.0-00010101000000-000000000000
)
