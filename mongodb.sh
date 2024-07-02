#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE
VALIDATE(){
    if [$1 -ne 0]
    then
        echo -e "$2 ...$R FAILED $N"
        exit 1
    else
        echo -e "$2....$G SUCESSS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "$G You are root user $N"
fi 
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied mongodb"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "installed mongodb"
systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enable mongod mongodb"
systemctl start mongod >> $LOGFILE
VALIDATE $? "start mongod"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "network connection"
systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting MongoDB"