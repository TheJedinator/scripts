# Prune first 
git prune && git remote prune origin && git remote prune upstream

# Clean up Branches that have been merged 
git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -D

# Clean branches that are gone 
git branch -vv | grep ': gone]'|  grep -v "\*" | awk '{ print $1; }' | xargs git branch -D