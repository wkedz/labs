## RUN
run-dev:
	fastapi dev
run-pro:
	fastapi run
run-raw:
	uvicorn main:app --reload

## ENV
env-create:
	python3 -m venv fastapi-tut

# It will only work within make context
#env-activate:
#	. ./fastapi-tut/bin/activate

env-deactivate:
	deactivate

env-clea:
	rm -rf ./fastapi-tut

install:
	poetry install --no-root
