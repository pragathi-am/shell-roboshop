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

dnf install mongodb-org -y
validate $? "Installing Mangodb "

systemctl enable mongod 
validate $? "enable Mangod "

systemctl start mongod 
validate $? "start Mangod "

sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/mongod.conf
validate $? "allowing remote connections "

systemctl restart mongod
validate $? "restart mangod"


echo " installing ngnix"
dnf install nginx -y &>> $LOGS_FILE    # store command output to logfile

# call validate function here after installation by passing args exitcode $? and pkgname

validate $? "nginx"

echo " installing mysql"
dnf install mysql -y &>> $LOGS_FILE

validate $? "mysql"

echo " installing nodejs"
dnf install nodejs -y &>> $LOGS_FILE

validate $? "nodejs"