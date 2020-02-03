checkStr="/origin/develop"
# for k in $(git branch -r | sed /master\*/d); do 
for k in $(git branch -r | grep -vwE "(master|develop)"); do 
  if [ -z "$(git log -1 --since='Jan 30, 2019' -s $k)" ]; then
    branch_name_with_no_origin=$(echo $k | sed -e "s/origin\///")
    echo deleting branch: $branch_name_with_no_origin
    # UNCOMMENT THE LINE BELOW TO ACTUALLY DELETE
    # git push origin --delete $branch_name_with_no_origin
  fi
done
