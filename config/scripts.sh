#!/bin/bash

# put your functions here in this format:

function compress() {
    tar cvzf $1.tar.gz $1
}
