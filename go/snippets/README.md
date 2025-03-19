# go-playground

This repo contains some code snippets written in go. 

# Commands

  # Heap stack analyze

  go tool compile -m GO_FILE - analyze the initial code.


  go run -gcflags="-m" 
  go build -gcflags="-m" 

  # Disable DWARF (debugger) generation

  go build -ldflags=-w


  # modules

  go mod verify - this will verify that the checksums of the downloaded packages on your machine match the entries in go.sum

  go mod download - download all the dependencies for the project

  ## upgrading packages 

  go get -u github.com/foo/bar

  go get -u github.com/foo/bar@v2.0.0

  ## removing packages

  go get github.com/foo/bar@none

  go mod tidy 
# Information / documentation

go doc PACKAGE_NAME

# Tests

## Benchmarking

  go test -bench=.

## Coverage

  go test -cover

## Race condition

  go test -race

## More 

  go test --help

# Go workspace 

go work init name - name new workspace 

go work use name -add new folder to workspace 

