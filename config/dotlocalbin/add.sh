#!/usr/bin/env bash

# hide my private info with a public stub
cd $HOME
public.sh

#add, commit and push
cd $HOME/zaneyos
git add *

# restore my private info and sync. I think the sync is not necessary, so I will comment it out.
cd $HOME
private.sh
#phoenix sync user
