#!/bin/bash
# This script takes 5 input variables
# ./push.sh {AWS_REGION} {AWS_PROFILE} {SOURCE_CODE} {ECR_URL} {IMAGE_TAG}

# Set Variables
set -e

AWS_REGION="$1"
AWS_PROFILE="$2"
SOURCE_CODE="$3"
ECR_URL="$4"
IMAGE_TAG="$5"

IMAGE_NAME=$(echo $SOURCE_CODE | cut -d'/' -f2)
BASE_URL=$(echo $ECR_URL | cut -d'/' -f1)

# Get authentication token and authenticate the Docker client against the registry
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin $BASE_URL

# Build the Docker Image Locally 
cd $SOURCE_CODE && DOCKER_BUILDKIT=0 docker build -t $IMAGE_NAME .

# Tag the Docker Image:
docker tag $IMAGE_NAME $ECR_URL:$IMAGE_TAG

# Push the Docker Image:
docker push $ECR_URL:$IMAGE_TAG