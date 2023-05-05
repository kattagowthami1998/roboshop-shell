script_path=$(dirname $0)
source $(script_path)/common.sh

curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
useradd ${app_user}
rm -rf /app
mkdir /app
curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip
cd /app
unzip /tmp/user.zip
cd /app
npm install
cp ${script_path}/user.service /etc/systemd/system/user.service
systemctl daemon-reload
systemctl enable user
systemctl restart user

cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo
yum install mongodb-org-shell -y
mongo --host mongodb-dev.gowthamidevops.online </app/schema/user.js