set -e
set -o pipefail


while getopts v:s:e:p:g:b: flag
do
    case "${flag}" in
        v) VPCID=${OPTARG};;
        s) SUBNETS=${OPTARG};;
        e) email=${OPTARG};;
        p) phone_number=${OPTARG};;
        g) github=${OPTARG};;
        b) BRANCH=${OPTARG};;
    esac
done


aws cloudformation create-stack --stack-name mazeECR --template-body file://ECRcloudformation.json --parameters ParameterKey=ApplicationName,ParameterValue=mazeservice ParameterKey=AlertEmail,ParameterValue=$email ParameterKey=AlertPhone,ParameterValue=$phone_number ParameterKey=GithubURL,ParameterValue=$github --capabilities CAPABILITY_NAMED_IAM

aws cloudformation wait stack-create-complete --stack-name mazeECR

export ECRURI=$(aws cloudformation describe-stacks --stack-name mazeECR --query "Stacks[0].Outputs[?OutputKey=='ECRURI'].OutputValue" --output text)
export TOPICARN=$(aws cloudformation describe-stacks --stack-name mazeECR --query "Stacks[0].Outputs[?OutputKey=='UpdateTopic'].OutputValue" --output text)


export BUILDID=$(aws codebuild start-build --project-name stage-mazeservice-build --source-version $BRANCH --environment-variables-override name=IMAGE_TAG,value=latest,type=PLAINTEXT --query "build.id" --output text)

export BUILDSTATUS=$(aws codebuild batch-get-builds --ids $BUILDID --query "builds[0].buildStatus" --output text)

while [ $BUILDSTATUS != "SUCCEEDED" ]; do sleep 20; BUILDSTATUS=$(aws codebuild batch-get-builds --ids $BUILDID --query "builds[0].buildStatus" --output text); echo $BUILDSTATUS; done


# create the privat key
aws ec2 create-key-pair --key-name maze-test --query KeyMaterial --output text >> MazePrivateKey.pem

# Create the stack
aws cloudformation create-stack --stack-name mazeIT --notification-arns $TOPICARN --template-body file://InfrastructureCloudformation.json --parameters ParameterKey=ECRURI,ParameterValue=$ECRURI  ParameterKey=AlertEmail,ParameterValue=$email ParameterKey=AlertPhone,ParameterValue=$phone_number ParameterKey=ApplicationName,ParameterValue=mazeservice ParameterKey=VpcId,ParameterValue=$VPCID ParameterKey=Subnets,ParameterValue=$SUBNETS --capabilities CAPABILITY_NAMED_IAM --tags Key=environment,Value=maze

aws cloudformation wait stack-create-complete --stack-name mazeIT

aws cloudformation describe-stacks --stack-name mazeIT --query "Stacks[0].Outputs[0].OutputValue" --output text