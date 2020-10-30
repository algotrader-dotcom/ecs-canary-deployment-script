#!/bin/bash
### Required: 
### 1 - AWS CLI V2: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
### 2 - Packages: git, jq, docker

## 1 - Initialize & create ecr repo
export AWS_DEFAULT_REGION=eu-west-1
export ecs_repo='ecs-sample-app'

aws ecr create-repository --repository-name $ecs_repo --region eu-west-1

## 2 - Build docker image v1 & v2
cd Docker/
echo "Repo: "$ecs_repo
sleep 5

docker build -t $ecs_repo .
docker tag $ecs_repo:latest 703043637716.dkr.ecr.eu-west-1.amazonaws.com/$ecs_repo:v1
3aws ecr get-login --no-include-email --registry-ids 703043637716| bash
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 703043637716.dkr.ecr.eu-west-1.amazonaws.com/$ecs_repo

docker push 703043637716.dkr.ecr.eu-west-1.amazonaws.com/$ecs_repo:v1

cd ../

git fetch && git checkout v2

cd Docker/

echo "Repo: "$ecs_repo
sleep 5

docker build -t $ecs_repo .
docker tag $ecs_repo:latest 703043637716.dkr.ecr.eu-west-1.amazonaws.com/$ecs_repo:v2
3aws ecr get-login --no-include-email --registry-ids 703043637716| bash
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 703043637716.dkr.ecr.eu-west-1.amazonaws.com/$ecs_repo

docker push 703043637716.dkr.ecr.eu-west-1.amazonaws.com/$ecs_repo:v2

cd ../

## 3 - Launch stack
stack_name='stack-ecs-canary'
aws cloudformation create-stack --stackname $stack_nameb--template-body file:///stack-ecs-canary.yaml --parameters file:///stack-ecs-canary-params.json 

## 4 - Create ECS service
aws ecs create-service --cli-input-json file://create_service.json --region eu-west-1

## 5 - CodeDeploy resources
aws deploy create-application --application-name ecs-blog-app --compute-platform ECS --region eu-west-1

aws deploy create-deployment-group --cli-input-json file://code_deployment_group.json --region eu-west-1
