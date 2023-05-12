app_user=roboshop
script=$(realpath "$0")
script_path=$(dirname "$script")
log_file=/tmp/roboshop.log
# rm -f $log_file

func_print_head(){
  echo -e "\e[35m>>>>>> $1 <<<<<<\e[0m"
  echo -e "\e[35m>>>>>> $1 <<<<<<\e[0m" &>>$log_file
}

func_stat_check() {

      if [ $1 -eq 0 ]; then
      echo -e "\e[32m>>>SUCCESS<<<\e[0m"
      else
      echo -e "\e[31m>>>Failure<<<\e[0m"
      echo "Refer the log file /tmp/roboshop.log for more information"
      exit 1
      fi
}

func_schema_setup() {
    if [ "$schema_setup" == "mongo" ]; then
    func_print_head "Copy Mongo repo"
    cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
    func_stat_check $?

    func_print_head "Install Mongo client"
    yum install mongodb-org-shell -y &>>$log_file
    func_stat_check $?

    func_print_head "Load schema"
    mongo --host mongodb-dev.gowthamidevops.online </app/schema/${component}.js &>>$log_file
    func_stat_check $?
    fi

    if [ "$schema_setup" == "mysql" ]; then

    func_print_head "Install MYSQL"
    yum install mysql -y &>>$log_file
    func_stat_check $?

    func_print_head "Load schema"
    mysql -h  mysql-dev.gowthamidevops.online -uroot -p${mysql_root_password} < /app/schema/shipping.sql &>>$log_file
    func_stat_check $?
  fi
  }

func_app_prereq() {
      func_print_head "create application user"
      id ${app_user} &>>$log_file
      if [ $? -ne 0 ]; then
      useradd ${app_user} &>>$log_file
      fi
      func_stat_check $?

      func_print_head "create application directory"
      rm -rf /app &>>$log_file
      mkdir /app  &>>$log_file
      func_stat_check $?

      func_print_head "Download app content"
      curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>$log_file
      func_stat_check $?

      func_print_head "unzip app content"
      cd /app
      unzip /tmp/${component}.zip &>>$log_file
      func_stat_check $?
}

func_systemd_setup() {

  func_print_head "copy service"
  cp $script_path/${component}.service /etc/systemd/system/${component}.service &>>$log_file
  func_stat_check $?

   func_print_head "start ${component} service"
    systemctl daemon-reload &>>$log_file
    systemctl enable ${component} &>>$log_file
    systemctl restart ${component} &>>$log_file
    func_stat_check $?
    }


func_nodejs() {

   func_print_head "Configure Nodejs repo"
   curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$log_file
   func_stat_check $?

    func_print_head "install Nodejs repo"
    yum install nodejs -y &>>$log_file
    func_stat_check $?

    func_app_prereq

    func_print_head "Install Nodejs dependencies"
    npm install &>>$log_file
    func_stat_check $?

    func_systemd_setup
    func_schema_setup
}

func_java() {
  func_print_head "Install Maven"
  yum install maven -y &>>$log_file
  func_stat_check $?

  func_app_prereq

  func_print_head "Download maven dependencies"
  mvn clean package  &>>$log_file
  mv target/${component}-1.0.jar ${component}.jar  &>>$log_file
  func_stat_check $?

  func_schema_setup
  func_systemd_setup
 }

 func_python(){

 func_print_head "Install python"
 yum install python36 gcc python3-devel -y &>>$log_file
 func_stat_check $?

 func_app_prereq

 func_print_head "Install python dependencies"
 pip3.6 install -r requirements.txt &>>$log_file
 func_stat_check $?

func_print_head "Update Passwords in System Service file"
 sed -i -e "s|rabbit_mq_appuser_password|${rabbit_mq_appuser_password}|" $script_path/payment.service &>>$log_file
 func_stat_check $?

 func_systemd_setup

}