#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=$mongodb.bujji.online
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling nodejs"
dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enableing nodejs"
dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installing nodejs"
id roboshop
if [$? ne 0]
then
    useradd roboshop
    VALIDATE $? "adding roboshop"
else
    echo -e "user roboshop already existed"
fi

mkdir -p /app
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading catalog"
cd /app 

unzip -o /tmp/catalogue.zip  &>> $LOGFILE
VALIDATE $? "unzipping catalogue"

npm install  &>> $LOGFILE

VALIDATE $? "Installing dependencies"
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service file"
systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGDB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalouge data into MongoDB"