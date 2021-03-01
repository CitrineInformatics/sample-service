while getopts v:s:e:p flag
do
    case "${flag}" in
        v) VPCID=${OPTARG};;
        s) subnets=${OPTARG};;
        e) email=${OPTARG};;
        p) phone_number=${OPTARG};;
    esac
done


aws cloudformation create-stack --stack-name ecrMaze --template-body file://ECRcloudformation.json --parameters ParameterKey=ApplicationName,ParameterValue=mazeservice 

export ECRURI=$(aws cloudformation describe-stacks --stack-name ecrMaze --query "Stacks[0].Outputs[0].OutputValue" --output text)
export TOPICARN=$(aws cloudformation describe-stacks --stack-name ecrMaze --query "Stacks[0].Outputs[1].OutputValue" --output text)

cd ..

echo AWSREGION=$(aws configure get region)

docker build  -t $ECRURI:latest .
aws ecr get-login-password --region $AWSREGION | docker login --username AWS --password-stdin $ECRURI
docker push $ECRURI:latest 

# create the privat key
aws ec2 create-key-pair --key-name maze-test --query KeyMaterial --output text >> MazePrivateKey.pem

# Create the stack
cd script
aws cloudformation create-stack --stack-name ecrMazeIT --notification-arns $TOPICARN --template-body file://InfrastructureCloudformation.json --parameters ParameterKey=ECRURI,ParameterValue=$ECRURI  ParameterKey=AlertEmail,ParameterValue=$email ParameterKey=AlertPhone,ParameterValue=$phone_number ParameterKey=ApplicationName,ParameterValue=mazeservice ParameterKey=VpcId,ParameterValue=$VPCID ParameterKey=Subnets,ParameterValue=$SUBNETS --capabilities CAPABILITY_NAMED_IAM --tags Key=environment,Value=maze

aws cloudformation describe-stacks --stack-name ecrMazeIT --query "Stacks[0].Outputs[0].OutputValue" --output text