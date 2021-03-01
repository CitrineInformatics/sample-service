

export NEWDOCKERTAG=$1

export ECRURI=$(aws cloudformation describe-stacks --stack-name ecrMaze --query "Stacks[0].Outputs[0].OutputValue" --output text)

cd ..

echo AWSREGION=$(aws configure get region)

docker build  -t $ECRURI:$DOCKERTAG .
aws ecr get-login-password --region $AWSREGION | docker login --username AWS --password-stdin $ECRURI
docker push $ECRURI:$DOCKERTAG 

aws cloudformation update-stack --stack-name ecrMazeIT --use-previous-template --parameters ParameterKey=DockerTag,ParameterValue=$NEWDOCKERTAG ParameterKey=AlertEmail,UsePreviousValue=true ParameterKey=AlertPhone,UsePreviousValue=true ParameterKey=ECRURI,UsePreviousValue=true ParameterKey=VpcId,UsePreviousValue=true ParameterKey=Subnets,UsePreviousValue=true --capabilities CAPABILITY_NAMED_IAM
