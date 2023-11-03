#!/bin/bash

ROLE_NAME="$1"

if [ -z "$ROLE_NAME" ]; then
  echo "Por favor, forneça o nome da função IAM como argumento."
  exit 1
fi

# Verifique se a função IAM já existe
aws iam get-role --role-name "$ROLE_NAME" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "$ROLE_NAME"
else
  echo -n ""
fi
