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

dnf install mysql-server -y &>> $LOG_FILE_NAME
VALIDATE &? "INSTALLING mySQL server"

systemctl enable mysqld  &>> $LOG_FILE_NAME
VALIDATE &? "ENABLING MySQL server"
 
systemctl start mysqld &>> $LOG_FILE_NAME
VALIDATE &? " STARTING MySQL server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE &? " Setting Root Password"


