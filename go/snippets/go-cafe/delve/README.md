#Installation

$ git clone https://github.com/go-delve/delve
$ cd delve
$ go install github.com/go-delve/delve/cmd/dlv

on Go 1.16 or later

# Install the latest release:
$ go install github.com/go-delve/delve/cmd/dlv@latest

# Install at tree head:
$ go install github.com/go-delve/delve/cmd/dlv@master

# Install at a specific version or pseudo-version:
$ go install github.com/go-delve/delve/cmd/dlv@v1.7.3

$ go get github.com/go-delve/delve/cmd/dlv

# Command

dlv debug PATH_TO_FILE

dlv debug [EMPTY] - debug module

# inside dlv

# help

# list main.go:10 - view file from line 10

# break main.go:10 -set a breakpoint on line 10

# break file_name.function_name set break point on function_name insisde file_name

# breakpoint - list all breakpoints 

# clear NUMBER - clear NUMBER breakpoint

# clearall - clears all breakpoints

# continue - run until breakpoint or program termination

# next - step over to nex source line

# print - show variables

# restart - restart process 

# step  - single step through program - go insive function

# stepout - go outside function

# stack - display callstack
delve set two additional breakpoints :
* runtime-fatal-throw - for 
* unrecovered-panic 