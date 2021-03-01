# README
## Pre-Requirements

### AWS CLI

Setup and install the AWS CLI v2 on your local machine:

 [AWS guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)


Setup your connection in the AWS config file with your user credentials and desired region

[AWS guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

(Deployment was tested in us-west-2, you will need to change the AMI if switching the AWS region)

### Connecting your AWS Account to your GitHub Repo

Go there and connect your GitHub to your AWS account to allow codebuild to build the container.
Select GitHub in the source, click connect to your GitHub account and follow the prompt.

[codebuild wizard](https://us-west-2.console.aws.amazon.com/codesuite/codebuild/project/new?region=us-west-2)

( No need to finalize the code build wizard)

## Setup the Infrastructure for the Maze Service

The Automation first creates an ECR to store all the versions of the docker images.
Then it creates the codebuild service for the container creation, tagging and publishing.
(The codebuild will build based off a branch in the GitHub repo)

The second cloudformation template creates the infrastructure needed to deploy a service behind a load balancer with an auto scaling group.

It also creates three logs groups:
- <b>Cloudformation Log,</b> group with the instance setup logs
- <b>Docker Log</b> group with the application logs
- The<b> Codebuild log </b> with the docker build logs


### List of Options
1. -v: VPC id
2. -s: Subnets
3. -e: email to alert
4. -p: phone number to alert
4. -g: github url to build the container on
6. -b: branch to build off

Go in the scripts folder to execute it:

 (Here is an example)

<pre><code>sh setupInfrastructure.sh -v vpc-a3f6fac5 -s subnet-09515a52\\,subnet-77394d3f\\,subnet-77267211 -e derory.quentin@gmail.com -p 6502293066 -g 'https://github.com/quentinDERORY/sample-service' -b Quentin-NewInfraForMaze
</code></pre>

## Execute a Rolling Update with a New Version

It will launch the build of the container from the supplied branch and push that new version to AWS.
The update will perform a rolling update on the autoscaling group and alert the user when finished
### List of Options
1. First option: Tag of the docker container
2. Second option: Branch to trigger the build off

Go in the scripts folder to execute it:

 (Here is an example)

<pre><code>sh setupInfrastructure.sh 3.0 Quentin-NewInfraForMaze
</code></pre>
