#!/bin/sh -l

GITHUB_TOKEN=$1
GITHUB_USER=$2
GITHUB_EMAIL=$3
OWNER=$4
WORKING_DIRECTORY=$5
BRANCH=$6
SKIP_TAG=$7
DEFAULT_BRANCH=$8

[ -z "${GITHUB_TOKEN}" ] && { echo "Missing input.token!"; exit 2; }
[ -z "${GITHUB_USER}" ] && { echo "Missing input.user!"; exit 2; }
[ -z "${GITHUB_EMAIL}" ] && { echo "Missing input.email!"; exit 2; }

echo "Setting up access to GitHub Package Registry"
mkdir -p ~/.gem
touch ~/.gem/credentials
chmod 600 ~/.gem/credentials
echo ":github: Bearer ${GITHUB_TOKEN}" >> ~/.gem/credentials

if [ -z "${SKIP_TAG}" ]
then
  echo "Installing gem-release"
  gem install gem-release

  echo "Setting gitub user"
  git config --global user.name ${GITHUB_USER}
  git config --global user.email ${GITHUB_EMAIL}

  git pull origin ${BRANCH:-$DEFAULT_BRANCH}

  echo "Bumping and pushing tags"
  version_pattern=$([[ -z "${BRANCH}" ]] && printf "patch" || printf "pre")
  gem bump -v $version_pattern

  gem tag

  git push origin ${BRANCH:-$DEFAULT_BRANCH}
  echo "Pushing code to branch ${BRANCH:-$DEFAULT_BRANCH}"

  git push --tags
else
  echo "Skipping Bumping and pushing tags"
fi

echo "Setting safe workspace directory"
git config --global --add safe.directory ${WORKING_DIRECTORY:-.}

echo "Building the gem"
gem build ${WORKING_DIRECTORY:-.}/*.gemspec
echo "Pushing the built gem to GitHub Package Registry"
gem push --key github --host "https://rubygems.pkg.github.com/${OWNER:-contratadome}" ./*.gem
