[
  {
    "name": "${app_name}",
    "image": "${app_image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "memoryReservation": ${memory},
    "resourceRequirements": null,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${app_port},
        "protocol": "tcp"
      }
    ],
    "environment": null,
    "environmentFiles": [],
    "secrets": null,
    "mountPoints": null,
    "volumesFrom": null,
    "hostname": null,
    "user": null,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${app_cw_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "${app_cw_stream}"
      }
    },
    "extraHosts": null,
    "ulimits": null,
    "dockerLabels": null,
    "dependsOn": null,
    "healthCheck": null,
    "interval": 60,
    "timeout": 10,
    "startPeriod": 30,
    "retries": 1
  }
]