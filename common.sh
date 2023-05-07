app_user=roboshop

print_head(){
  echo -e "\e[35m>>>>>> $1 <<<<<<\e[0m"
}

schema_setup(){
  if [ $schema_setup == "mongo"];then
  print_head "Copy Mongo repo"
  cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo

  print_head "Install Mongo client"
 yum install mongodb-org-shell -y

  print_head "Load schema"
  mongo --host mongodb-dev.gowthamidevops.online </app/schema/${component}.js

  fi
}

func_nodejs() {
 print_head "Configure Nodejs repo"
 curl -sL https://rpm.nodesource.com/setup_lts.x | bash

 print_head "install Nodejs repo"
  yum install nodejs -y

  print_head "Add application user"
  useradd ${app_user}

  print_head "create application directory"
  rm -rf /app
  mkdir /app

  print_head "Download app content"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip

  print_head "unzip app content"
  cd /app
  unzip /tmp/${component}.zip

  print_head "Install Nodejs dependencies"
  npm install

  print_head "copy catalogue service"
  cp $script_path/${component}.service /etc/systemd/system/${component}.service

  print_head "start catalogue service"
  systemctl daemon-reload
  systemctl enable ${component}
  systemctl restart ${component}

  schema_setup
}