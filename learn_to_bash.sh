#!/bin/bash

function println
{
    # Send each element as a separate argument, starting with the second element.
    # Arguments to printf:
    #   1 -> "$1\n"
    #   2 -> "$2"
    #   3 -> "$3"
    #   4 -> "$4"
    #   etc.
    echo "\$1 is $1"
    echo "\$2 is $2"
    printf "$1\n" "${@:2}"
   #printf '\e[32mError (%d): %s\e[m\n'
}

function error
{
    # Send the first element as one argument, and the rest of the elements as a combined argument.
    # Arguments to println:
    #   1 -> '\e[31mError (%d): %s\e[m'
    #   2 -> "$1"
    #   3 -> "${*:2}"

    println '\e[31mError (%d): %s\e[m' "$1" "${*:2}"
    #exit "$1"
}

# This...
error 1234 Something went wrong.
# And this...
error 1234 'Something went wrong.' "wronger"
# Result in the same output (as long as $IFS has not been modified).
