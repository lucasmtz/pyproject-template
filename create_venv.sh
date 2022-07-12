#!/bin/bash
# Template repository name
TEMPLATE_NAME="pyproject-template"

# Create package folder
echo
echo "Creating package folder..."
REPO_NAME=$(basename "$(pwd)")
PKG_NAME="${REPO_NAME//-/_}"
mkdir -m 777 "$PKG_NAME"
mkdir -m 777 "$PKG_NAME/tests"
touch $PKG_NAME/__init__.py
touch $PKG_NAME/tests/__init__.py
REPO_URL="$(git config --get remote.origin.url)"
BASE_URL=$(basename "$REPO_URL" | cut -d "." -f -1)

# Replace words in README, setup.cfg and pre-commit-config
echo
echo "Replacing words in README, setup.cfg and pre-commit-config..."
sed -i 's@'"${TEMPLATE_NAME^^}"'@'"${REPO_NAME^^}"'@g' README.md
sed -i 's@'"${TEMPLATE_NAME}"'@'"${REPO_NAME}"'@g' README.md
sed -i 's@'"${TEMPLATE_NAME//-/_}"'@'"${PKG_NAME}"'@g' README.md
sed -i 's@package_name@'"${PKG_NAME}"'@g' setup.cfg
sed -i 's@package_name@'"${PKG_NAME}"'@g' .pre-commit-config.yaml

# Create virtual enviroment
echo
echo "Creating virtual environment..."
rm -rf venv
python3 -m pip install --upgrade pip setuptools wheel
python3 -m venv venv
chmod -R 777 venv/
source venv/bin/activate

# Install versioneer
echo
echo "Installing versioneer..."
pip3 install versioneer

# Delete template git repository and start a new one
if [ "$BASE_URL" == "$TEMPLATE_NAME" ]; then
    echo
    echo "Deleting template git repository..."
    rm -rf .git
    echo "Initializing new git repository..."
    git init -b main
fi

# Finish versioneer installation for the project
if ! test -f "versioneer.py"; then
    echo
    echo "Finishing versioneer installation..."
    sed -i '/from.*_version/d' $PKG_NAME/__init__.py
    sed -i '/__version__.*\]/d' $PKG_NAME/__init__.py
    sed -i '/./,$!d' $PKG_NAME/__init__.py
    versioneer install
fi

# Install project in editable mode
echo
echo "Installing project in editable mode..."
pip3 install -e .[dev]

# Install pre-commit and do the first commmit
if [ "$BASE_URL" == "$TEMPLATE_NAME" ]; then
    echo
    echo "Installing pre-commit and doing the first commit..."
    pre-commit install
    pre-commit autoupdate
    pre-commit run --all-files
    pre-commit run --all-files
    pre-commit run --all-files
    git add .
    git commit -m "Initial commit"
    echo "Initializing git flow..."
    git flow init -d -t 'v'
fi

# Check versioneer
echo
python setup.py version
echo

# Success message
echo "SUCCESS! $REPO_NAME repository is ready to use."
