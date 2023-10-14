#!/bin/bash

for region in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
    echo "Zonas de Disponibilidade na região $region:"
    aws ec2 describe-availability-zones --region $region --query 'AvailabilityZones[].ZoneName' --output text
done



#For Exemple
#Zona s de Disponibilidade na região ap-south-1:
#ap-south-1a     ap-south-1b     ap-south-1c
#Zonas de Disponibilidade na região eu-north-1:
#Zonas de Disponibilidade na região eu-west-3:
#eu-west-3a      eu-west-3b      eu-west-3c
#Zonas de Disponibilidade na região eu-west-2:
#eu-west-2a      eu-west-2b      eu-west-2c
#Zonas de Disponibilidade na região eu-south-2:
#eu-south-2a     eu-south-2b     eu-south-2c
#Zonas de Disponibilidade na região eu-west-1:
#eu-west-1a      eu-west-1b      eu-west-1c
#Zonas de Disponibilidade na região ap-northeast-3:
#ap-northeast-3a ap-northeast-3b ap-northeast-3c
#Zonas de Disponibilidade na região ap-northeast-2:
#ap-northeast-2a ap-northeast-2b ap-northeast-2c ap-northeast-2d
#Zonas de Disponibilidade na região ap-northeast-1:
#ap-northeast-1a ap-northeast-1c ap-northeast-1d
#Zonas de Disponibilidade na região il-central-1:
#il-central-1a   il-central-1b   il-central-1c
#Zonas de Disponibilidade na região ca-central-1:
#ca-central-1a   ca-central-1b   ca-central-1d
#Zonas de Disponibilidade na região sa-east-1:
#sa-east-1a      sa-east-1b      sa-east-1c
#Zonas de Disponibilidade na região ap-southeast-1:
#ap-southeast-1a ap-southeast-1b ap-southeast-1c
#Zonas de Disponibilidade na região ap-southeast-2:
#ap-southeast-2a ap-southeast-2b ap-southeast-2c
#Zonas de Disponibilidade na região eu-central-1:
#eu-central-1a   eu-central-1b   eu-central-1c
#Zonas de Disponibilidade na região us-east-1:
#us-east-1a      us-east-1b      us-east-1c      us-east-1d      us-east-1e      us-east-1f
#Zonas de Disponibilidade na região us-east-2:
#us-east-2a      us-east-2b      us-east-2c
#Zonas de Disponibilidade na região us-west-1:
#us-west-1a      us-west-1b
#Zonas de Disponibilidade na região us-west-2:
#us-west-2a      us-west-2b      us-west-2c      us-west-2d