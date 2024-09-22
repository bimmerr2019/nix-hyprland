#!/usr/bin/env bash

# Check if a commit message was provided
if [ $# -eq 0 ]; then
    echo "Error: No commit message provided. Please run the script with a commit message."
    echo "Usage: $0 <commit message>"
    exit 1
fi

# hide my private info with a public stub
cd $HOME
public.sh

#add, commit and push
cd $HOME/zaneyos
git add *
git commit -m "$1"
git push -u origin main

# restore my private info and sync. I think the sync is not necessary, so I will comment it out.
cd $HOME
private.sh
#phoenix sync user
