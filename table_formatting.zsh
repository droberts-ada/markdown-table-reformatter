#!env zsh

echo_time() {
  date +"%Y-%m-%d %H:%M:%S $*"
}

if [[ -d .git ]] ; then
  echo_time "You are currently in a git repo! I need an empty directory to work in - please make one for me and run me again."
  exit 1
fi

LOCATION=`greadlink -f ${0%/*}`
PROJECT_LIST_FILE="$LOCATION/projects.txt"
COMMIT_MESSAGE="$LOCATION/commit_message.txt"
SED_EXPRESSION='s/^\|\s*([^\|]*[^ \t\|])\s*\|\s*([^\|]*[^ \t\|])?\s*\|\s*$/\1 | \2/g'
FILES_TO_CONVERT=('feedback.md' 'PULL_REQUEST_TEMPLATE' 'PULL_REQUEST_TEMPLATE.md' '.github/PULL_REQUEST_TEMPLATE' '.github/PULL_REQUEST_TEMPLATE.md')

echo_time "Converting to concise table formatting!"

for PROJECT in `tail -r $PROJECT_LIST_FILE | grep -v "^#"`; do
  echo_time

  if [[ -d $PROJECT ]] ; then
    echo_time "Folder $PROJECT already exists. I will not touch it."
  fi

  REPO="git@github.com:AdaGold/$PROJECT.git"
  echo_time "Converting $PROJECT in repo $REPO"

  git clone $REPO
  cd $PROJECT

  echo_time "Now in folder `pwd`"
  for FILE in $FILES_TO_CONVERT; do
    if [[ -e $FILE ]]; then
      echo_time "Converting $FILE"
      sed --in-place -E --expression=$SED_EXPRESSION $FILE
      git add $FILE
    fi
  done

  DIFF_FILE="../$PROJECT.diff"
  echo_time "Logging changes for $PROJECT to $DIFF_FILE"
  git diff --staged > $DIFF_FILE

  echo_time "Finished changes for repo $PROJECT, committing and pushing"
  git commit -F $COMMIT_MESSAGE
  git push

  cd ..

done

echo_time "Done!"
