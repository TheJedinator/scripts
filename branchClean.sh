# Prune first 
git prune && git remote prune origin && git remote prune upstream

# Clean up Branches that have been merged 
git branch --merged | egrep -v "(^\*|master|develop|dev)" | xargs git branch -D

# Clean branches that are gone 
git branch -vv | grep ': gone]'|  grep -v "\*" | awk '{ print $1; }' | xargs -r git branch -D
