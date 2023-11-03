#!/bin/bash

INSTANCE_PROFILE_NAME="$1"
AWS_REGION="$2" # Recebe a região como o segundo argumento

if [ -z "$INSTANCE_PROFILE_NAME" ]; then
  echo "Por favor, forneça o nome da instance profile como o primeiro argumento."
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  echo "Por favor, forneça a região da AWS como o segundo argumento."
  exit 1
fi

# Defina a região desejada
export AWS_DEFAULT_REGION="$AWS_REGION"

# Verifique se a instance profile já existe
aws iam get-instance-profile --no-paginate --instance-profile-name "$INSTANCE_PROFILE_NAME" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "$INSTANCE_PROFILE_NAME"
else
  echo -n ""
fi
