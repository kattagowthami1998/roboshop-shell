app_user=roboshop
log_file=/tmp/roboshop.log

print_head(){
  echo -e "\e[35m>>>>>> $1 <<<<<<\e[0m"
  echo -e "\e[35m>>>>>> $1 <<<<<<\e[0m" &>>$log_file
}

func_stat_check(){

      if[ $1 eq 0 ]; then
      echo -e "\e[32m>>>SUCCESS<<<\e[0m"
      else
      echo -e "\e[31m>>>Failure<<<\e[0m"
      exit 1
      fi
}

func_schema_setup() {
    if [ "$schema_setup" == "mongo" ]; then
    print_head "Copy Mongo repo"
    cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
    func_stat_check $?

    print_head "Install Mongo client"
    yum install mongodb-org-shell -y &>>$log_file
    func_stat_check $?

    print_head "Load schema"
    mongo --host mongodb-dev.gowthamidevops.online </app/schema/${component}.js &>>$log_file
    func_stat_check $?

    fi

    if [ "$schema_setup" == "mysql" ]; then

    print_head "Install MYSQL"
    yum install mysql -y &>>$log_file
    func_stat_check $?

    print_head "Load schema"
    mysql -h  mysql-dev.gowthamidevops.online -uroot -p${mysql_root_password} < /app/schema/shipping.sql &>>$log_file
    func_stat_check $?

  fi
  }

func_app_prereq() {
      print_head "Add application user"
      id ${app_user} &>>$log_file
      if [ $? ne 0 ]; then
      useradd ${app_user} &>>$log_file
      fi
      func_stat_check $?

      print_head "create application directory"
      rm -rf /app &>>$log_file
      mkdir /app  &>>$log_file
      func_stat_check $?

      print_head "Download app content"
      curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>$log_file
      func_stat_check $?

      print_head "unzip app content"
      cd /app
      unzip /tmp/${component}.zip &>>$log_file
      func_stat_check $?
}

func_systemd_setup() {

  print_head "copy catalogue service"
  cp $script_path/${component}.service /etc/systemd/system/${component}.service &>>$log_file
  func_stat_check $?

   print_head "start catalogue service"
    systemctl daemon-reload &>>$log_file
    systemctl enable ${component} &>>$log_file
    systemctl restart ${component} &>>$log_file
    func_stat_check $?
    }


func_nodejs() {

   print_head "Configure Nodejs repo"
   curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$log_file
   func_stat_check $?

    print_head "install Nodejs repo"
    yum install nodejs -y &>>$log_file
    func_stat_check $?

    func_app_prereq

    print_head "Install Nodejs dependencies"
    npm install &>>$log_file
    func_stat_check $?

    func_systemd_setup
    func_schema_setup
}

func_java() {
  print_head "Install Maven"
  yum install maven -y &>>$log_file
  func_stat_check $?

  func_app_prereq

  print_head "Download maven dependencies"
  mvn clean package  &>>$log_file
  mv target/{component}-1.0.jar {component}.jar  &>>$log_file
  func_stat_check $?

  func_schema_setup
  func_systemd_setup
 }