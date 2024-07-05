ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.bujji.online
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

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user app"
cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "unzipping"

npm install &>> $LOGFILE

VALIDATE $? "installing npm"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying user service file"
VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user"
cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGDB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into MongoDB"