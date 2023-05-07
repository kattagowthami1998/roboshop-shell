script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
mysql_root_password=$1

if [ -z "$my_sql_root_password" ]; then
  echo input MYSQL root password missing
  exit
  fi

component=shiping
schema_setup=mysql
func_java