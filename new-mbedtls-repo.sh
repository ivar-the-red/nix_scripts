#!/usr/bin/bash
# $1 is the name of the parent folder to be created

export MBEDTLS_GITHUB=git@github.com:Mbed-TLS/mbedtls.git

validate_arguments() {
    if [ "$1" = "" ]; then
        echo "You need to supply a parent folder name argument. Exiting..."
        exit 1
    fi
}

in_repos() {
    [[ "$(pwd)" = "/home/ivar/repos" ]] && return
    false
}

verify_dir() {
    if in_repos; then
        echo "In repositories folder..."
    else
        echo "Navigating to repositories folder..."
        cd /home/ivar/repos
        echo "Done..."
    fi
}

create_parent_dir() {
    mkdir $1
    cd $1
}

create_app_dir() {
    mkdir app
}

create_new_dirs() {
    create_parent_dir $1
    create_app_dir
}

clone_mbedtls() {
    git clone $MBEDTLS_GITHUB
}

build_mbedtls() {
    cd mbedtls
    make clean && make -j2 lib
    cd -
}

create_app_dir_files() {
    cd app
    touch app.c Makefile
    cd -
}

populate_makefile() {
    cd app
    cat <<'END' > Makefile
# Compiler and flags for the program
CC = gcc
CFLAGS = -Wall -Werror -g -I../mbedtls/include

# Directory
SRCDIR = .

# Source file for the program
SRC = $(wildcard $(SRCDIR)/*.c)

# Target program
PROGRAM = app

all: $(PROGRAM)

$(PROGRAM): $(SRC)
	$(CC) $(CFLAGS) -o $@ $(SRC) -L../mbedtls/library -lmbedtls -lmbedcrypto -lmbedx509

clean:
	rm -f $(PROGRAM)

.PHONY: all clean
END
    cd -
}

populate_main() {
    cd app
    cat <<'END' > app.c
/* System includes */
#include <stdio.h>
#include <stdlib.h>

/* Mbed TLS includes */


int main (int argc, char** argv)
{

    return EXIT_SUCCESS;
}
END
    cd -
}

populate_files() {
    populate_makefile
    populate_main
}

main() {
	validate_arguments $1
	verify_dir
	create_new_dirs $1
	create_app_dir_files
	populate_files
	clone_mbedtls
	build_mbedtls
}

main $1