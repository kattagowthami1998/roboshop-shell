script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

func_print_head "Disable MySQL 8 Version"
dnf module disable mysql -y &>>$log_file
func_stat_check $?

func_print_head "copying mysql.repo"
cp ${script_path}/mysql.repo /etc/yum.repos.d/mysql.repo &>>$log_file
func_stat_check $?

func_print_head "install mysql.repo"
yum install mysql-community-server -y &>>$log_file
func_stat_check $?

func_print_head "start mysql"
systemctl enable mysqld &>>$log_file
systemctl restart mysqld &>>$log_file
func_stat_check $?

func_print_head "set userid & pw"
mysql_secure_installation --set-root-pass $mysql_root_password &>>$log_file
#mysql -uroot -pRoboShop@1 &>>$log_file
func_stat_check $?