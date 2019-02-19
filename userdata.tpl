#! /bin/bash
#install .net core packages
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm

#install updates
sudo yum update -y

#install .net core
#sudo yum install dotnet-runtime-2.1.x86_64 -y
sudo yum install aspnetcore-runtime-2.1.x86_64  -y

#install application
aws s3 ls
aws s3 cp s3://${code_bucket}/webapplication.zip .
unzip webapplication.zip

#run application
cd publish
runuser -u ec2-user dotnet WebApplication1.dll > log.txt &