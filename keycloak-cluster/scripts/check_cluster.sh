#!/bin/bash

# Setup color variables
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

# Function to check service status
check_service() {
    local service=$1
    local container="${service}-container"
    local status=$(docker inspect --format='{{.State.Status}}' $container 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo -e "${COLOR_RED}ERROR: Container $container does not exist.${COLOR_RESET}"
        return 1
    elif [ "$status" = "running" ]; then
        echo -e "${COLOR_GREEN}✓ $service is running${COLOR_RESET}"
        return 0
    else
        echo -e "${COLOR_RED}✗ $service is not running (status: $status)${COLOR_RESET}"
        return 1
    fi
}

# Function to check service health
check_health() {
    local service=$1
    local container="${service}-container"
    local health=$(docker inspect --format='{{.State.Health.Status}}' $container 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo -e "${COLOR_RED}ERROR: Container $container does not exist.${COLOR_RESET}"
        return 1
    elif [ "$health" = "healthy" ]; then
        echo -e "${COLOR_GREEN}✓ $service is healthy${COLOR_RESET}"
        return 0
    elif [ "$health" = "starting" ]; then
        echo -e "${COLOR_YELLOW}⟳ $service is still starting${COLOR_RESET}"
        return 2
    else
        echo -e "${COLOR_RED}✗ $service is unhealthy (status: $health)${COLOR_RESET}"
        return 1
    fi
}

# Function to check Keycloak node
check_keycloak_node() {
    local node=$1
    local container="${node}-node${2}"
    local status=$(docker inspect --format='{{.State.Status}}' $container 2>/dev/null)
    local health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}N/A{{end}}' $container 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo -e "${COLOR_RED}ERROR: Container $container does not exist.${COLOR_RESET}"
        return 1
    elif [ "$status" = "running" ]; then
        if [ "$health" = "healthy" ]; then
            echo -e "${COLOR_GREEN}✓ $node node $2 is running and healthy${COLOR_RESET}"
        elif [ "$health" = "starting" ]; then
            echo -e "${COLOR_YELLOW}⟳ $node node $2 is running but still initializing${COLOR_RESET}"
        elif [ "$health" = "N/A" ]; then
            echo -e "${COLOR_YELLOW}? $node node $2 is running but health check not available${COLOR_RESET}"
        else
            echo -e "${COLOR_RED}! $node node $2 is running but unhealthy (status: $health)${COLOR_RESET}"
        fi
        return 0
    else
        echo -e "${COLOR_RED}✗ $node node $2 is not running (status: $status)${COLOR_RESET}"
        return 1
    fi
}

# Print header
echo -e "${COLOR_BLUE}=== Keycloak Cluster Status Check ===${COLOR_RESET}"
echo -e "${COLOR_BLUE}$(date)${COLOR_RESET}"
echo ""

# Check MySQL status
echo -e "${COLOR_BLUE}Checking database service:${COLOR_RESET}"
check_service "mysql"
check_health "mysql"
echo ""

# Check Keycloak nodes
echo -e "${COLOR_BLUE}Checking Keycloak nodes:${COLOR_RESET}"
check_keycloak_node "keycloak" "1"
check_keycloak_node "keycloak" "2"
echo ""

# Check Nginx status
echo -e "${COLOR_BLUE}Checking load balancer:${COLOR_RESET}"
check_service "nginx"
echo ""

# Check HTTP connectivity
echo -e "${COLOR_BLUE}Checking HTTP connectivity:${COLOR_RESET}"
source "$(dirname "$0")/../docker-compose/.env"
HTTP_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://${SERVER_IP:-localhost})
if [ "$HTTP_CHECK" = "200" ] || [ "$HTTP_CHECK" = "302" ]; then
    echo -e "${COLOR_GREEN}✓ HTTP endpoint responded with code $HTTP_CHECK${COLOR_RESET}"
else
    echo -e "${COLOR_RED}✗ HTTP endpoint returned unexpected code: $HTTP_CHECK${COLOR_RESET}"
fi
echo ""

# Print summary
echo -e "${COLOR_BLUE}=== Summary ===${COLOR_RESET}"
total_nodes=$(docker ps --filter "name=keycloak-node" --format "{{.Names}}" | wc -l)
running_nodes=$(docker ps --filter "name=keycloak-node" --filter "status=running" --format "{{.Names}}" | wc -l)
echo -e "Total Keycloak nodes: $total_nodes"
echo -e "Running Keycloak nodes: $running_nodes"

if [ "$running_nodes" -eq 0 ]; then
    echo -e "${COLOR_RED}CRITICAL: No Keycloak nodes are running!${COLOR_RESET}"
    exit 2
elif [ "$running_nodes" -lt "$total_nodes" ]; then
    echo -e "${COLOR_YELLOW}WARNING: Not all Keycloak nodes are running.${COLOR_RESET}"
    exit 1
else
    echo -e "${COLOR_GREEN}OK: All Keycloak nodes are running.${COLOR_RESET}"
    exit 0
fi 