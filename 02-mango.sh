#!/bin/bash
#to install mangodb after instance creation 

# to know id of user id . for root user this is always zero
userid=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"  # no color

if [ $userid -ne 0 ]; then
   echo " please run with sudo user" | tee -a $LOGS_FILE  # tee writes screen output to log file by apend mode
   
   exit 1
fi
mkdir -p $LOGS_FOLDER

# this function will not execute by shell. it will execute only when it being called .
validate() {
  if [ $1 -ne 0 ]; then 
   echo -e " $2 .... $R failed $N" | tee -a $LOGS_FILE
   exit 1
  else
   echo -e " $2 .... $G success $N" | tee -a $LOGS_FILE
  fi   
}

cp mango.repo /etc/yum.repos.d/mongo.repo
validate $? "copying Mango Repo"

dnf install mongodb-org -y &>>$LOGS_FILE
validate $? "Installing Mangodb "

systemctl enable mongod &>>$LOGS_FILE
validate $? "enable Mangod "

systemctl start mongod &>>$LOGS_FILE
validate $? "start Mangod "

sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/mongod.conf
validate $? "allowing remote connections "

systemctl restart mongod &>>$LOGS_FILE
validate $? "restart mangod"
