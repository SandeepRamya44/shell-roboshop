#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script started executed at: $(date)"

if [ $USERID -ne 0 ]; then
    echo "Error: PLease run the script with root access" | tee -a $LOG_FILE
    exit 1 # failure is other than zero
fi

VALIDATE(){

        if [ $1 ne 0 ]; then
            echo -e "$2....$R is failure $N" 
            exit 1
        else
            echo -e "$2....$G is Success $N"
        fi
    
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing Mongo db"

systemctl enable mongod -y &>>$LOG_FILE
VALIDATE $? "enable Mongo db"

systemctl start mongod -y &>>$LOG_FILE
VALIDATE $? "start Mongo db"