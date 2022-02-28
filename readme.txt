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

# AWS Configuration Multiple Profiles
aws configure set aws_access_key_id XXXXXXXX --profile default
aws configure set aws_secret_access_key XXXXXXXX --profile default

aws configure set aws_access_key_id XXXXXXXX --profile dev
aws configure set aws_secret_access_key XXXXXXXX --profile dev

aws configure set aws_access_key_id XXXXXXXX --profile prod
aws configure set aws_secret_access_key XXXXXXXX --profile prod


# S3 Backend Manual Setup
aws --profile dev s3 mb s3://wilton-terraform-state-backend --region sa-east-1

aws --profile dev s3api put-bucket-versioning \
    --bucket wilton-terraform-state-backend --versioning-configuration Status=Enabled

aws --profile dev s3api put-bucket-encryption \
    --bucket wilton-terraform-state-backend \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

aws --profile dev s3api put-object-lock-configuration \
    --bucket wilton-terraform-state-backend \
    --object-lock-configuration '{"ObjectLockEnabled": "Enabled"}'

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

docker run -it --rm -v $PWD/demo-app:/code -w/code  openjdk:11-jdk sh -c './mvnw package'
docker run -it --rm -v $PWD/demo-app:/code -w/code  openjdk:11-jdk sh -c './gradlew build -i'