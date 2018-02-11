#!env zsh

if [[ -d .git ]] ; then
  echo "You are currently in a git repo! I need an empty directory to work in - please make one for me and run me again."
  exit 1
fi

LOCATION=${0%/*}
PROJECT_LIST_FILE="$LOCATION/projects.txt"
SED_EXPRESSION='s/^\|\s*([^\|]*[^ \t\|])\s*\|\s*([^\|]*[^ \t\|])?\s*\|\s*$/\1 | \2/g'
FILES_TO_CONVERT=('feedback.md' 'PULL_REQUEST_TEMPLATE' '.github/PULL_REQUEST_TEMPLATE')
COMMIT_MESSAGE="$LOCATION/commit_message.txt"


echo "Converting to concise table formatting!"

for PROJECT in `tail -r $PROJECT_LIST_FILE | grep -v "^#"`; do
  echo

  REPO="git@github.com:AdaGold/$PROJECT.git"
  echo "Converting $PROJECT in repo $REPO"

  git clone $REPO
  cd $PROJECT

  echo "Now in folder `pwd`"
  for FILE in $FILES_TO_CONVERT; do
    if [[ -e $FILE ]]; then
      echo "Converting $FILE"
      sed --in-place -E --expression=$SED_EXPRESSION $FILE
      git add $FILE
    fi
  done

  DIFF_FILE="../$PROJECT.diff"
  echo "Logging changes for $PROJECT to $DIFF_FILE"
  git diff --staged > ../$DIFF_FILE

  echo "Finished changes for repo $PROJECT, committing and pushing"
  git commit -F $COMMIT_MESSAGE
  git push

  cd ..

done

# PROJECT="Grocery-Store"
#
