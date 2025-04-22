#!/bin/bash

# Set up colored output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set up GitHub repository information
GITHUB_USERNAME="vinhluong"
GITHUB_REPO_NAME="key-cloak"
GITHUB_REPO_URL="https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO_NAME}.git"

# Base directory for the project
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC_DIR="${BASE_DIR}/keycloak-cluster/keycloak-src"

# Function to check dependency installation
check_dependency() {
    local dep_name=$1
    local check_cmd=$2
    
    echo -e "${BLUE}Checking for ${dep_name}...${NC}"
    if command -v $check_cmd >/dev/null 2>&1; then
        echo -e "${GREEN}✓ ${dep_name} is installed.${NC}"
        return 0
    else
        echo -e "${RED}✗ ${dep_name} is not installed. Please install it before continuing.${NC}"
        return 1
    fi
}

# Check for required dependencies
check_dependency "Git" "git" || exit 1
check_dependency "GitHub CLI" "gh" || exit 1

# Check if the user is logged in to GitHub
echo -e "${BLUE}Checking GitHub authentication...${NC}"
if ! gh auth status >/dev/null 2>&1; then
    echo -e "${YELLOW}You need to authenticate with GitHub. Running 'gh auth login'...${NC}"
    gh auth login
else
    echo -e "${GREEN}✓ GitHub authentication is configured.${NC}"
fi

# Clone Keycloak repository
echo -e "${BLUE}Setting up Keycloak source code...${NC}"
if [ -d "$SRC_DIR" ]; then
    echo -e "${YELLOW}Source directory already exists at $SRC_DIR${NC}"
    read -p "Would you like to remove it and clone again? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Removing existing directory...${NC}"
        rm -rf "$SRC_DIR"
    else
        echo -e "${YELLOW}Keeping existing directory. Make sure it's properly configured.${NC}"
        exit 0
    fi
fi

# Clone the official Keycloak repository
echo -e "${BLUE}Cloning official Keycloak repository...${NC}"
git clone https://github.com/keycloak/keycloak.git "$SRC_DIR"

# Get available Keycloak versions
cd "$SRC_DIR"
echo -e "${BLUE}Available Keycloak versions:${NC}"
git tag | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -10

# Ask user to select a version
echo -e "${YELLOW}Enter the version to use (empty for latest version):${NC}"
read KC_VERSION

if [ -z "$KC_VERSION" ]; then
    BRANCH_NAME="custom-main"
    echo -e "${GREEN}Using latest version on branch: ${BRANCH_NAME}${NC}"
else
    BRANCH_NAME="custom-${KC_VERSION}"
    # Checkout the specific version
    git checkout $KC_VERSION
    echo -e "${GREEN}Using Keycloak version ${KC_VERSION} on branch: ${BRANCH_NAME}${NC}"
fi

# Create a new branch for customization
git checkout -b $BRANCH_NAME

# Set up GitHub repository
echo -e "${BLUE}Setting up GitHub repository...${NC}"
echo -e "${GREEN}Using repository: ${GITHUB_REPO_URL}${NC}"

# Set the remote URL
git remote remove origin 2>/dev/null || true
git remote add origin $GITHUB_REPO_URL

# Check if the repository already has content
echo -e "${BLUE}Checking if the repository already has content...${NC}"
if git ls-remote --exit-code $GITHUB_REPO_URL main >/dev/null 2>&1; then
    echo -e "${YELLOW}Repository already has content. Pulling from main branch...${NC}"
    git fetch origin main
    git merge origin/main --allow-unrelated-histories -m "Merge with existing repository" || {
        echo -e "${RED}Failed to merge with existing repository. Please resolve conflicts manually.${NC}"
        exit 1
    }
else
    echo -e "${GREEN}Repository is empty. Setting up initial content.${NC}"
    # Create README file
    echo "# Custom Keycloak for Cluster Setup" > README.md
    echo "" >> README.md
    echo "This repository contains a customized version of Keycloak for use in a clustered environment." >> README.md
    echo "" >> README.md
    echo "## Custom Components" >> README.md
    echo "" >> README.md
    echo "Custom themes, providers, and extensions can be found in the 'custom-extensions' directory." >> README.md
    
    # Create directory for custom plugins
    mkdir -p custom-extensions
    touch custom-extensions/.gitkeep
    
    # Commit and push initial content
    git add README.md custom-extensions/.gitkeep
    git commit -m "Initial setup for custom Keycloak"
fi

# Push to GitHub
echo -e "${BLUE}Pushing to GitHub repository...${NC}"
git push -u origin $BRANCH_NAME

# Update .env file with repository information
ENV_FILE="${BASE_DIR}/keycloak-cluster/docker-compose/.env"
if [ -f "$ENV_FILE" ]; then
    echo -e "${BLUE}Updating .env file with repository information...${NC}"
    sed -i "s#^KEYCLOAK_REPO_URL=.*#KEYCLOAK_REPO_URL=${GITHUB_REPO_URL}#g" "$ENV_FILE"
    sed -i "s#^KEYCLOAK_BRANCH=.*#KEYCLOAK_BRANCH=${BRANCH_NAME}#g" "$ENV_FILE"
    echo -e "${GREEN}✓ .env file updated.${NC}"
else
    echo -e "${YELLOW}Warning: .env file not found at ${ENV_FILE}${NC}"
    echo -e "${YELLOW}Make sure to set the following environment variables manually:${NC}"
    echo -e "${YELLOW}KEYCLOAK_REPO_URL=${GITHUB_REPO_URL}${NC}"
    echo -e "${YELLOW}KEYCLOAK_BRANCH=${BRANCH_NAME}${NC}"
fi

# Summary
echo -e "\n${GREEN}=== Repository Setup Complete ===${NC}"
echo -e "${GREEN}Repository URL: ${GITHUB_REPO_URL}${NC}"
echo -e "${GREEN}Branch: ${BRANCH_NAME}${NC}"
echo -e "${GREEN}Source directory: ${SRC_DIR}${NC}"

echo -e "\n${BLUE}Next steps:${NC}"
echo -e "1. Make your desired customizations to the Keycloak source code"
echo -e "2. Commit and push your changes to GitHub:"
echo -e "   ${YELLOW}cd ${SRC_DIR}${NC}"
echo -e "   ${YELLOW}git add .${NC}"
echo -e "   ${YELLOW}git commit -m \"Your custom changes\"${NC}"
echo -e "   ${YELLOW}git push origin ${BRANCH_NAME}${NC}"
echo -e "3. Build and run your customized Keycloak container:"
echo -e "   ${YELLOW}cd ${BASE_DIR}/keycloak-cluster/docker-compose${NC}"
echo -e "   ${YELLOW}docker-compose up -d --build${NC}"

exit 0 