script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
rabbit_mq_password=$1

if [ -z "$rabbit_mq_password" ]; then
  echo Input Roboshop app user password missing
  exit 1
fi

component=payment
func_python