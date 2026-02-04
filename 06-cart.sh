#!/bin/bash

# to know id of user id . for root user this is always zero
userid=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"  # no color
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER

if [ $userid -ne 0 ]; then
   echo " please run with sudo user" | tee -a $LOGS_FILE  # tee writes screen output to log file by apend mode
   exit 1
fi


# this function will not execute by shell. it will execute only when it being called .
validate() {
  if [ $1 -ne 0 ]; then 
   echo -e " $2 .... $R failed $N" | tee -a $LOGS_FILE
   exit 1
  else
   echo -e " $2 .... $G success $N" | tee -a $LOGS_FILE
  fi   
}

dnf module list nodejs &>>$LOGS_FILE
validate $? "list all nodejs"

dnf module disable nodejs -y &>>$LOGS_FILE
validate $? "diable nodejs "

dnf module enable nodejs:20 -y &>>$LOGS_FILE
validate $? "enable nodejs "

dnf install nodejs -y &>>$LOGS_FILE
validate $? "install nodejs "

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then 
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
     validate $? "setting up roboshop system user "
else
    echo -e "system user already exist. hence $R skipping $N"
fi

mkdir -p /app 
validate $? "creatin app dir "

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
validate $? "downloading app to temp zip folder "

cd /app
rm -rf /app/* &>>$LOGS_FILE
validate $? "removing existing content"

unzip /tmp/cart.zip
validate $? "unzipping to app folder "

npm install &>>$LOGS_FILE
validate $? "istall npm"

cp  $SCRIPT_DIR/cart.service  /etc/systemd/system/cart.service
validate $? "copying cart.service to system dir"

systemctl daemon-reload
systemctl enable cart &>>$LOGS_FILE
systemctl start cart
validate $? "enable and start systemctl"

