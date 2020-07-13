#!/bin/sh -l

GITHUB_TOKEN=$1
GITHUB_USER=$2
GITHUB_EMAIL=$3
OWNER=$4
WORKING_DIRECTORY=$5

[ -z "${GITHUB_TOKEN}" ] && { echo "Missing input.token!"; exit 2; }
[ -z "${GITHUB_USER}" ] && { echo "Missing input.user!"; exit 2; }
[ -z "${GITHUB_EMAIL}" ] && { echo "Missing input.email!"; exit 2; }

echo "Bumping and pushing tags"
git config --global user.name ${{ secrets.DEFAULT_USER }}
git config --global user.email ${{ secrets.DEFAULT_EMAIL }}
gem bump
gem tag
git push origin master --force-with-lease
git push --tags

echo "Setting up access to GitHub Package Registry"
mkdir -p ~/.gem
touch ~/.gem/credentials
chmod 600 ~/.gem/credentials
echo ":github: Bearer ${GITHUB_TOKEN}" >> ~/.gem/credentials

echo "Building the gem"
gem build ${WORKING_DIRECTORY:-.}/*.gemspec
echo "Pushing the built gem to GitHub Package Registry"
gem push --key github --host "https://rubygems.pkg.github.com/${OWNER:-contratadome}" ./*.gem
