script_path=$(dirname $0)
source $(script_path)/common.sh

echo -e "/e[36m>>>>Disable MYSQL<<</e]0m"
dnf module disable mysql -y

echo -e "/e[36m>>>>copying mysql.repo<<</e]0m"
cp ${script_path}/mysql.repo /etc/yum.repos.d/mysql.repo

echo -e "/e[36m>>>>update listen address <<</e]0m"
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/redis.conf
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/redis/redis.conf

echo -e "/e[36m>>>>install mysql.repo<<</e]0m"
yum install mysql-community-server -y

echo -e "/e[36m>>>>start mysql<<</e]0m"
systemctl enable mysqld
systemctl restart mysqld

echo -e "/e[36m>>>>set userid & pw<<</e]0m"
mysql_secure_installation --set-root-pass RoboShop@1
mysql -uroot -pRoboShop@1