set -e
set -o pipefail

export NEWDOCKERTAG=$1
export BRANCH=$2

export ECRURI=$(aws cloudformation describe-stacks --stack-name mazeECR --query "Stacks[0].Outputs[?OutputKey=='ECRURI'].OutputValue" --output text)

export BUILDID=$(aws codebuild start-build --project-name stage-mazeservice-build --source-version $BRANCH --environment-variables-override name=IMAGE_TAG,value=$NEWDOCKERTAG,type=PLAINTEXT --query "build.id" --output text)

export BUILDSTATUS=$(aws codebuild batch-get-builds --ids $BUILDID --query "builds[0].buildStatus" --output text)

while [ $BUILDSTATUS != "SUCCEEDED" ]; do sleep 20; BUILDSTATUS=$(aws codebuild batch-get-builds --ids $BUILDID --query "builds[0].buildStatus" --output text); echo $BUILDSTATUS; done

aws cloudformation update-stack --stack-name mazeIT --use-previous-template --parameters ParameterKey=DockerTag,ParameterValue=$NEWDOCKERTAG ParameterKey=AlertEmail,UsePreviousValue=true ParameterKey=AlertPhone,UsePreviousValue=true ParameterKey=ECRURI,UsePreviousValue=true ParameterKey=VpcId,UsePreviousValue=true ParameterKey=Subnets,UsePreviousValue=true --capabilities CAPABILITY_NAMED_IAM

aws cloudformation wait stack-update-complete --stack-name mazeIT
