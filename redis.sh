yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
dnf module enable redis:remi-6.2 -y
yum install redis -y
systemctl enable redis
systemctl start redis

# need to change port from 127.0.0.1 to 0.0.0.0