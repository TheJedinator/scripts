#!/bin/bash

# regex to match Jira case names (e.g "EIGEN-123")
case_name_pattern=[A-Z][A-Z]*-[0-9][0-9]*

# Get the current branch. If the branch name contains what looks like a Jira case, strip out
# the rest of the branch name.
case_name=`git branch | awk '/\*/ { print $2; }' | sed "s/\(${case_name_pattern}\)-.*/\1/"`
# If the branch name doesn't contain a Jira case, $case_name now just contains the name of
# the branch.
if [[ ! $case_name =~ ${case_name_pattern}$ ]]; then
    case_name=""
fi
# If the branch name contains a Jira case, $case_name now contains that case. Otherwise,
# $case_name is an empty string.


# This case statement detects if we're merging, rebasing, using a commit message template,
# etc. Currently we only do anything in the case of a normal commit where a template
# "git commit -t ..." or a message "git commit -m ..." has NOT been specified.
case "$2,$3" in
  ,)
    # If $case-name is not empty, add the case name to the commit message
    if [[ ! -z $case_name ]]
    then
      # sed -i "1a ${case_name}" $1
      sed -i.bak -e "1s/^/${case_name}\n /" $1
    fi;;

  *) ;;
esac

