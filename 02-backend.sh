#!/bin/bash

USERID=$( id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m" #it has to give, other wise previous mentioned color will contine 

LOG_FOLDER="/var/log/expense-log" # /var/log/shell-script.log 
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H:%M:%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
     if [ $1 -ne 0 ]
 then
    echo -e "$2 .....$R FAILURE $N"
    exit 2
 else
    echo -e "$2 ....$G SUCCESS $N"
 fi
}

echo "script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
         echo "ERROR:: you must have sudo access to execute this script"
         exit 1 # other than 0
     fi
}

dnf module disable nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Disabling existing default NodeJS"

dnf module enable nodejs:20 -y &>> $LOG_FILE_NAME
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing NodeJs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
     useradd expense &>> $LOG_FILE_NAME
     VALIDATE $? "adding expense user"
else
     echo -e "expense user already exists....$Y SKIPPING $N"
fi
         
mkdir -p /app &>> $LOG_FILE_NAME
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE_NAME
VALIDATE $? "downloading backend"

cd /app

rm -rf /app/* 

unzip /tmp/backend.zip &>> $LOG_FILE_NAME
VALIDATE $? "unzip the file"

npm install &>> $LOG_FILE_NAME
VALIDATE $? "installing depencies"

cp /home/ec2-user/expense-shellscript/backend.service /etc/systemd/system/backend.service

#prepare mysql schema

dnf install mysql -y &>> $LOG_FILE_NAME
VALIDATE $? "installing mysql"

mysql -h mysql.poojari.store -u root -pExpenseApp@1 < /app/schema/backend.sql &>> $LOG_FILE_NAME
VALIDATE $? "setting up the transaction schema and tables"

systemctl daemon-reload &>> $LOG_FILE_NAME
VALIDATE $? "Daemon reload"

systemctl enable backend &>> $LOG_FILE_NAME
VALIDATE $? "enabling backend"

systemctl restart backend &>> $LOG_FILE_NAME
VALIDATE $? "starting backend"