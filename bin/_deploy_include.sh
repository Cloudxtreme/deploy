#!/bin/sh

build_it_now() {
    mkdir -p /var/ports/packages/All
    echo "building ${1}"
    safename=$( echo "${1}" | tr / _ )
    if [ -e /var/db/ports/${safename}/options ]; then
        rm /var/db/ports/${safename}/options
    fi
    cd /usr/ports/${1}
    make && make install && make package \
    && cp /var/ports/usr/ports/${1}/work/pkg/*.txz /var/ports/packages/All/ \
    && make clean
    ## see /var/ports/packages/All/
}

