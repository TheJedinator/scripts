# Prune first 
echo "pruning...."
git prune && git remote prune origin

# Clean up Branches that have been merged 
echo "cleaning up merged branches...."
git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -D

# Clean branches that are gone 
echo "cleaning up gone branches...."
git branch -vv | grep ': gone]'|  grep -v "\*" | awk '{ print $1; }' | xargs git branch -D
