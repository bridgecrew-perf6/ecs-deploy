#!/bin/bash

# Progress bar decorator functions:
decorator () {
    echo -e "Generating Task List: \n"
    echo -ne '[....................](00%)\r'
    sleep .5
    echo -ne '[#####...............](25%)\r'
    sleep .5
    echo -ne '[##########..........](50%)\r'
    sleep .5
    echo -ne '[###############.....](75%)\r'
    sleep .5
    echo -ne '[####################](100%)\r'
    echo -e '\n'
}

# Function to generate a list of task IDs (no aws profile):
generate_task_list () {
    TASK_LIST=$(aws ecs list-tasks --cluster $ECS_CLUSTER --family $CONTAINER_FAMILY --region $AWS_REGION | jq -r '.taskArns' | jq -r '.[]' | awk -F "/" '{print $3}')
    task_array=(${TASK_LIST/// })
    echo "Task ID List:"
    echo ""
    for i in "${!task_array[@]}"
        do
            echo "Task ID $i = ${task_array[i]}"
        done
}

# Function to generate a list of task IDs (when using an aws profile):
generate_task_list_profile () {
    TASK_LIST=$(aws ecs list-tasks --cluster $ECS_CLUSTER --family $CONTAINER_FAMILY --region $AWS_REGION --profile $AWS_PROFILE | jq -r '.taskArns' | jq -r '.[]' | awk -F "/" '{print $3}')
    task_array=(${TASK_LIST/// })
    echo "Task ID List:"
    echo ""
    for i in "${!task_array[@]}"
        do
            echo "Task ID $i = ${task_array[i]}"
        done
}

# Check if the necessary commands are installed
declare -A commands_array=(
    [session-manager-plugin]="https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
    [jq]="https://stedolan.github.io/jq/download/"
    [aws]="https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
)

for key in "${!commands_array[@]}"; 
do
    if command -v $key > /dev/null
        then
            echo "" > /dev/null
        else
            echo "[ERROR] $key not installed - Please install $key to continue"
            echo -e '\n'
            echo "Ref: ${commands_array[$key]}"
            echo -e '\n'
            exit 1
    fi
done

# Validate AWS CLI version:
INSTALLED_AWS_CLI_VERSION=$(aws --version | awk -F "/" '{print $2}' | awk -F " " '{print $1}')
if [[ ("$INSTALLED_AWS_CLI_VERSION" < "$REQUIRED_AWS_CLI_VERSION") ]]; then
    echo -e '\n'
    echo "[ERROR] AWS CLI version $REQUIRED_AWS_CLI_VERSION or higher is required"
    echo "Please update the AWS CLI and try again:"
    echo "Ref: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
else
    echo "" > /dev/null
fi

# Interactive prompt to start the SSM session in an ECS (Fargate) task:
PS3='Are you using a Profile? (Select an option): '
OPTIONS=("Yes" "No" "Quit")
select opt in "${OPTIONS[@]}"
do
	case $opt in
		"Yes")
            read -p "Input your AWS Profile Name: " AWS_PROFILE
            read -p "Input your AWS Region: " AWS_REGION
            read -p "Input the ECS Cluster Name: " ECS_CLUSTER
            read -p "Input the Container Family Name: " CONTAINER_FAMILY
            read -p "Input the Container Name: " CONTAINER_NAME
            decorator; generate_task_list_profile
            echo -e '\n'
            read -p "Input your Task ID (Copy and paste one of the above): " TASK_ID
            echo -e '\n'
            echo -e "[INFO] Using variales: $AWS_PROFILE $AWS_REGION $ECS_CLUSTER $CONTAINER_NAME $TASK_ID"
			aws ecs execute-command --cluster $ECS_CLUSTER --task $TASK_ID --container $CONTAINER_NAME --command "/bin/bash" --interactive --region $AWS_REGION --profile $AWS_PROFILE
			exit 0
			;;
		"No")
            read -p "Input your AWS Region: " AWS_REGION
            read -p "Input the ECS Cluster Name: " ECS_CLUSTER
            read -p "Input the Container Family Name: " CONTAINER_FAMILY
            read -p "Input the Container Name: " CONTAINER_NAME
            decorator; generate_task_list
            echo -e '\n'
            read -p "Input your Task ID (Copy and paste one of the above): " TASK_ID
            echo -e '\n'
            echo -e "[INFO] Using variales: $AWS_REGION $ECS_CLUSTER $CONTAINER_NAME $TASK_ID"
			aws ecs execute-command --cluster $ECS_CLUSTER --task $TASK_ID --container $CONTAINER_NAME --command "/bin/bash" --interactive --region $AWS_REGION
			exit 0
			;;
		"Quit")
			echo -e "[INFO] Script ended"
			break
			;;
		*)
			echo -e "[ERROR] $REPLY Is an invalid option - Select the option NUMBER, for example: 1"
			exit 1
			;;
	esac
done