echo -e "/e[36m>>>>Configure Nodejs repo<<<</e]0m"

curl -sL https://rpm.nodesource.com/setup_lts.x | bash

echo -e "/e[36m>>>>install Nodejs repo<<<</e]0m"
yum install nodejs -y

echo -e "/e[36m>>>>Add application user<<<</e]0m"
useradd roboshop

echo -e "/e[36m>>>>create application directory<<<</e]0m"
mkdir /app

echo -e "/e[36m>>>>Download app content<<<</e]0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip

echo -e "/e[36m>>>>unzip app content<<<</e]0m"
cd /app
unzip /tmp/catalogue.zip

echo -e "/e[36m>>>>Install Nodejs dependencies<<<</e]0m"
npm install

echo -e "/e[36m>>>>copy catalogue service<<<</e]0m"
cp catalogue.service /etc/systemd/system/catalogue.service

echo -e "/e[36m>>>>start catalogue service<<<</e]0m"
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue

echo -e "/e[36m>>>>copy mongorepo <<<</e]0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo

echo -e "/e[36m>>>>install mongodb client<<<</e]0m"
yum install mongodb-org-shell -y

echo -e "/e[36m>>>>Load schema<<<</e]0m"
mongo --host mongodb.gowthamidevops.online </app/schema/catalogue.js