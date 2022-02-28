# Terraform Installation
TF_VERSION="1.1.6"
ARCH=$(dpkg --print-architecture)
curl -fsSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_$ARCH.zip -o /tmp/terraform.zip
sudo unzip -q /tmp/terraform.zip -d /usr/local/bin
sudo chmod +x /usr/local/bin/terraform
rm /tmp/terraform.zip
terraform --version

# AWS CLI Installation
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip -q awscliv2.zip
sudo aws/install -i /usr/local/aws-cli -b /usr/local/bin --update
rm -rf awscliv2.zip aws/
aws --version
complete -C '/usr/local/bin/aws_completer' aws
echo "complete -C '/usr/local/bin/aws_completer' aws" >> ~/.bashrc

# AWS Configuration Multiple Profiles
aws configure set aws_access_key_id XXXXXXXX --profile default
aws configure set aws_secret_access_key XXXXXXXX --profile default

aws configure set aws_access_key_id XXXXXXXX --profile dev
aws configure set aws_secret_access_key XXXXXXXX --profile dev

aws configure set aws_access_key_id XXXXXXXX --profile prod
aws configure set aws_secret_access_key XXXXXXXX --profile prod


# S3 Backend Manual Setup
aws --profile dev s3api create-bucket \
    --bucket wilton-terraform-state-backend --create-bucket-configuration LocationConstraint=sa-east-1 --object-lock-enabled-for-bucket

aws --profile dev s3api put-bucket-versioning \
    --bucket wilton-terraform-state-backend --versioning-configuration Status=Enabled

aws --profile dev s3api put-bucket-encryption \
    --bucket wilton-terraform-state-backend \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

aws --profile dev s3api put-public-access-block \
    --bucket wilton-terraform-state-backend \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Demo App Gradle
curl -fsSL https://start.spring.io/starter.tgz \
  -d dependencies=web,actuator,prometheus \
  -d javaVersion=11 \
  -d packageName=com.example \
  -d groupId=com.example \
  -d artifactId=demo-app \
  -d baseDir=demo-app \
  -d type=gradle-project | tar -xzvf -

# Demo App Maven
curl -fsSL https://start.spring.io/starter.tgz \
  -d dependencies=web,actuator,prometheus \
  -d javaVersion=11 \
  -d packageName=com.example \
  -d groupId=com.example \
  -d artifactId=demo-app \
  -d baseDir=demo-app \
  -d type=maven-project | tar -xzvf -

# Gitignore
cat <<'EOF'> demo-app/.gitignore
!.gitignore
### Code ###
!src/**
### Maven ###
HELP.md
target
!mvnw
!mvnw.cmd
!.mvn/wrapper/*
!settings.xml
!pom.xml
### Gradle ###
HELP.md
.gradle
build/
!gradlew
!gradlew.bat
!gradle/wrapper/*
!init.gradle
!settings.gradle
!build.gradle
EOF

# Spring Properties as Env Variables
cat <<'EOF'> demo-app/env.txt
server_port=8080
server_shutdown=graceful
management_endpoints_web_exposure_include=health,info,prometheus
EOF

# Build with Gradle
docker run --name builder -it --rm -v $PWD/demo-app:/code -w /code  openjdk:11-jdk sh -c './gradlew build -i'

# Run and Test
docker run --name demo-app -it --rm -p 8080:8080 -v $PWD/demo-app:/code -w /code --env-file=$PWD/demo-app/env.txt  openjdk:11-jre java -jar build/libs/demo-app-0.0.1-SNAPSHOT.jar
curl -fsSL localhost:8080/actuator/health | jq

# Build with Maven
docker run --name builder -it --rm -v $PWD/demo-app:/code -w /code  openjdk:11-jdk sh -c './mvnw package'

# Run and Test
docker run --name demo-app -it --rm -p 8080:8080 -v $PWD/demo-app:/code -w /code --env-file=$PWD/demo-app/env.txt openjdk:11-jre java -jar target/demo-app-0.0.1-SNAPSHOT.jar
curl -fsSL localhost:8080/actuator/health | jq
