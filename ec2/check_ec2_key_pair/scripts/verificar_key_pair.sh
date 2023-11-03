#!/bin/bash

KEY_PAIR_NAME="$1"
AWS_REGION="$2" # Recebe a região como o segundo argumento

if [ -z "$KEY_PAIR_NAME" ]; then
  echo "Por favor, forneça o nome da keyPair como o primeiro argumento."
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  echo "Por favor, forneça a região da AWS como o segundo argumento."
  exit 1
fi

# Defina a região desejada
export AWS_DEFAULT_REGION="$AWS_REGION"

# Verifique se a keyPair já existe
aws ec2 describe-key-pairs --key-names "$KEY_PAIR_NAME" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "$KEY_PAIR_NAME"
else
  echo -n ""
fi
