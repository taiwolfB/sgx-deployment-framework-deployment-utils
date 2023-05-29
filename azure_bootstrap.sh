#!/bin/bash

mkdir azure_deployment
cd azure_deployment

sudo apt-get install docker-compose git -y

git clone https://github.com/taiwolfB/sgx-deployment-framework-remote-attestation.git
git clone https://github.com/taiwolfB/sgx-deployment-framework-frontend.git
git clone https://github.com/taiwolfB/sgx-deployment-framework-backend.git
git clone https://github.com/taiwolfB/sgx-deployment-framework-deployment-utils.git


sudo cp -r ./sgx-deployment-framework-remote-attestation ./sgx-deployment-framework-backend
sudo cp ./sgx-deployment-framework-deployment-utils/docker-compose.yml ./
sudo cp ./sgx-deployment-framework-deployment-utils/.env ./

export MACHINE_IP=$(curl ifconfig.me/ip)

export REACT_APP_VAR="REACT_APP_BACKEND_HOST=$MACHINE_IP"
export FRONTEND_HOST_VAR="FRONTEND_HOST=$MACHINE_IP" 
echo $REACT_APP_VAR >> .env
echo $FRONTEND_HOST_VAR >> .env

sudo cp ./.env ./sgx-deployment-framework-frontend

sudo docker-compose up -d 
