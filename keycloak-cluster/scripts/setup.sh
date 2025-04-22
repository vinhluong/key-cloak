#!/bin/bash

# Setup variables
SCRIPT_DIR=$(dirname "$(realpath "$0")")
BASE_DIR=$(dirname "${SCRIPT_DIR}")
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

# Create required directories
echo -e "${COLOR_BLUE}Creating directory structure...${COLOR_RESET}"
mkdir -p ${BASE_DIR}/{backups/{configs,mysql,volumes},certbot,mysql_data}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${COLOR_RED}ERROR: Docker is not installed${COLOR_RESET}"
    echo "Please install Docker and Docker Compose before proceeding."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${COLOR_RED}ERROR: Docker Compose is not installed${COLOR_RESET}"
    echo "Please install Docker Compose before proceeding."
    exit 1
fi

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null; then
    echo -e "${COLOR_RED}ERROR: OpenSSL is not installed${COLOR_RESET}"
    echo "Please install OpenSSL before proceeding."
    exit 1
fi

# Generate SSL certificates
echo -e "${COLOR_BLUE}Generating SSL certificates...${COLOR_RESET}"
${SCRIPT_DIR}/generate_ssl.sh
if [ $? -ne 0 ]; then
    echo -e "${COLOR_RED}Failed to generate SSL certificates${COLOR_RESET}"
    exit 1
fi

# Set appropriate permissions for script files
echo -e "${COLOR_BLUE}Setting file permissions...${COLOR_RESET}"
chmod +x ${SCRIPT_DIR}/*.sh

# Set up backup schedules
echo -e "${COLOR_BLUE}Setting up backup schedule...${COLOR_RESET}"
${SCRIPT_DIR}/setup_cron.sh
if [ $? -ne 0 ]; then
    echo -e "${COLOR_YELLOW}WARNING: Failed to set up cron jobs. Backups will not run automatically.${COLOR_RESET}"
fi

# Build and start the Docker Compose services
echo -e "${COLOR_BLUE}Building and starting Docker Compose services...${COLOR_RESET}"
cd ${BASE_DIR}/docker-compose
docker-compose up -d --build

# Check if the services are running
if [ $? -eq 0 ]; then
    echo -e "${COLOR_GREEN}Keycloak cluster with MySQL and Nginx has been successfully deployed!${COLOR_RESET}"
    echo ""
    echo "Access Keycloak at:"
    echo "  - HTTP: http://$(grep SERVER_IP ${BASE_DIR}/docker-compose/.env | cut -d '=' -f2)"
    echo "  - HTTPS: https://$(grep DOMAIN_NAME ${BASE_DIR}/docker-compose/.env | cut -d '=' -f2) (self-signed certificate)"
    echo ""
    echo "Keycloak Admin Console:"
    echo "  - Username: $(grep KEYCLOAK_ADMIN ${BASE_DIR}/docker-compose/.env | cut -d '=' -f2)"
    echo "  - Password: $(grep KEYCLOAK_ADMIN_PASSWORD ${BASE_DIR}/docker-compose/.env | cut -d '=' -f2)"
    echo ""
    echo "MySQL Database:"
    echo "  - Host: $(grep SERVER_IP ${BASE_DIR}/docker-compose/.env | cut -d '=' -f2)"
    echo "  - Port: 3306"
    echo "  - Database: $(grep MYSQL_DATABASE ${BASE_DIR}/docker-compose/.env | cut -d '=' -f2)"
    echo "  - Username: $(grep MYSQL_USER ${BASE_DIR}/docker-compose/.env | cut -d '=' -f2)"
    echo "  - Password: $(grep MYSQL_PASSWORD ${BASE_DIR}/docker-compose/.env | cut -d '=' -f2)"
    echo ""
    echo "Cluster Information:"
    echo "  - Node 1: keycloak1:8080"
    echo "  - Node 2: keycloak2:8080"
    echo "  - Load Balancer: Nginx with IP hash-based sticky sessions"
    echo ""
    echo "To check the status of the services:"
    echo "  cd ${BASE_DIR}/docker-compose && docker-compose ps"
else
    echo -e "${COLOR_RED}Failed to start the services. Please check the logs for more information:${COLOR_RESET}"
    echo "  cd ${BASE_DIR}/docker-compose && docker-compose logs"
    exit 1
fi 