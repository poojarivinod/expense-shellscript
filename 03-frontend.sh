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

mkdir -p $LOG_FOLDER

echo "script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
         echo "ERROR:: you must have sudo access to execute this script"
         exit 1 # other than 0
     fi
}

dnf install nginx -y  &>> $LOG_FILE_NAME
VALIDATE $? "INSTALLING nginx"

systemctl enable nginx  &>> $LOG_FILE_NAME
VALIDATE $? "Enabling nginx"

systemctl start nginx  &>> $LOG_FILE_NAME
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*  &>> $LOG_FILE_NAME
VALIDATE $? "removing existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip  &>> $LOG_FILE_NAME
VALIDATE $? "downloading latest code"

cd /usr/share/nginx/html 
VALIDATE $? "move to HTML directory"

unzip /tmp/frontend.zip  &>> $LOG_FILE_NAME
VALIDATE $? "unzipping frontend"

cp /home/ec2-user/expense-shellscript/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "copied expense config"

systemctl restart nginx  &>> $LOG_FILE_NAME
VALIDATE $? "restarting nginx"
