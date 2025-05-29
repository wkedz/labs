#!/bin/bash

# Based on https://www.digitalocean.com/community/tutorials/how-to-install-and-use-sqlite-on-ubuntu-20-04

sudo apt update
sudo apt install sqlite3

# Example

# sqlite3 sharks.db
## This will create a new database named sharks. If the file sharks.db already exists, 
## SQLite will open a connection to it; if it does not exist, SQLite will create it.

# .schema - display the schema of a table
# .tables - display all tables
# .exit - exit the SQLite shell
# .help - display help
# .open - open a database
# .save - save the current database to a file
# .timeout - set the timeout for database operations
# .databases - display all databases
# .headers - display or hide column headers
# .mode - set the output mode : columns, csv, insert, line, list, quote, tabs, tcl
# .nullvalue - set the string to use for NULL values
# .output - set the output file
# .print - print the current database
# .read - read a file and execute its commands


