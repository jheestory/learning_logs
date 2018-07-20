# !/bin/bash
# Apache 2.4  //  Python 3.6  //  MySQL 5.7  //  Django


# 아파치
mkdir -p /home1/irteam/apps/web
cd /home1/irteam/apps/web

wget http://mirror.navercorp.com/apache/httpd/httpd-2.4.29.tar.gz
wget http://mirror.navercorp.com/apache/apr/apr-1.6.3.tar.gz
wget http://mirror.navercorp.com/apache/apr/apr-util-1.6.1.tar.gz
wget http://downloads.sourceforge.net/project/pcre/pcre/8.41/pcre-8.41.tar.gz

tar xzf httpd-2.4.29.tar.gz
tar xzf apr-1.6.3.tar.gz
tar xzf apr-util-1.6.1.tar.gz
tar xzf pcre-8.41.tar.gz

cd /home1/irteam/apps/web/pcre-8.41
./configure
make && make install

cd /home1/irteam/apps/web
mv apr-1.6.3 httpd-2.4.29/srclib/apr
mv apr-util-1.6.1 httpd-2.4.29/srclib/apr-util

cd /home1/irteam/apps/web/httpd-2.4.29
./configure --prefix=/home1/irteam/apps/apache2
make; make install

# chown root:irteam /home1/irteam/apps/apache2/bin/apachectl
# chmod 4775 /home1/irteam/apps/apache2/bin/apachectl

echo "alias apachectl='/home1/irteam/apps/apache2/bin/apachectl'" >> ~/.bashrc


# MySQL
# yum install -y ncurses ncurses-devel cmake
# yum install -y git zlib*
# yum install -y bzip2-devel db4-devel gdbm-devel libpcap-devel ncurses-devel openssl-devel readline-devel sqlite-devel xz-devel zlib-devel
mkdir /home1/irteam/apps/data
cd /home1/irteam/apps/data

wget http://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz
wget mirror.koreaidc.com/mysql/mysql-5.7.9.tar.gz

tar xzf boost_1_59_0.tar.gz
tar xzf mysql-5.7.9.tar.gz

cd /home1/irteam/apps/data/mysql-5.7.9
cmake \
-DCMAKE_INSTALL_PREFIX=/home1/irteam/apps/mysql \
-DWITH_EXTRA_CHARSETS=all \
-DMYSQL_DATADIR=/home1/irteam/apps/mysql_data \
-DENABLED_LOCAL_INFILE=1 \
-DDOWNLOAD_BOOST=1 \
-DWITH_BOOST=../boost_1_59_0 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_UNIX_ADDR=/home1/irteam/apps/mysql/tmp/mysql.sock \
-DSYSCONFDIR=/etc \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=all

make; make install

echo "Servername "`hostname -I`:80 >> /home1/irteam/apps/apache2/conf/httpd.conf


cd /home1/irteam/apps/data

wget https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tgz
wget https://github.com/GrahamDumpleton/mod_wsgi/archive/4.4.13.tar.gz

tar xzf Python-3.6.4.tgz
tar xzf 4.4.13.tar.gz


cd /home1/irteam/apps/data/Python-3.6.4
./configure --prefix=/home1/irteam/apps/Python3 CFLAGS=-fPIC --enable-shared --with-threads
# ./configure --prefix=/home1/irteam/apps/Python3 CFLAGS=-fPIC --enable-shared
make; make install
cd /usr/lib64
ln -s /home1/irteam/apps/Python3/lib/libpython3.6m.so.1.0 ./


cd /home1/irteam/apps/data/mod_wsgi-4.4.13
# ln -s /home1/irteam/apps/apache2/bin/apxs /usr/bin/

./configure CFLAGS=-fPIC --with-python=/home1/irteam/apps/Python3/bin/python3 --prefix=/home1/irteam/apps/apache2/modules --with-apxs=/home1/irteam/apps/apache2/bin/apxs
make; make install

echo "#python3">>~/.bashrc
echo "alias python='/home1/irteam/apps/Python3/bin/python3'">>~/.bashrc
echo "alias pip='/home1/irteam/apps/Python3/bin/pip3'">>~/.bashrc
echo "alias django='/home1/irteam/apps/Python3/bin/django-admin.py'">>~/.bashrc

/home1/irteam/apps/Python3/bin/pip3 install django==1.8
/home1/irteam/apps/Python3/bin/pip3 install django-bootstrap3
/home1/irteam/apps/Python3/bin/pip3 install pymysql

mkdir -p /home1/irteam/apps/web_root
cd /home1/irteam/apps/web_root

git clone https://github.com/DaeGyeong/Django.git
cd /home1/irteam/apps/web_root/Django

# httpd.conf 파일 수정 합시다
ip=`hostname -I`
sed -i "s/#ServerName www.example.com/ServerName `hostname -I|cut -f 1 -d ' '`/g" /home1/irteam/apps/apache2/conf/httpd.conf

echo "LoadModule wsgi_module modules/mod_wsgi.so" >> /home1/irteam/apps/apache2/conf/httpd.conf
echo "WSGIScriptAlias / /home1/irteam/apps/web_root/Django/learning_log/wsgi.py" >> /home1/irteam/apps/apache2/conf/httpd.conf
echo "WSGIPythonPath /home1/irteam/apps/web_root/Django" >> /home1/irteam/apps/apache2/conf/httpd.conf
echo "WSGIDaemonProcess testdjango lang='ko_KR.UTF-8' locale='ko_KR.UTF-8'" >> /home1/irteam/apps/apache2/conf/httpd.conf
echo "<Directory /home1/irteam/apps/web_root/Django/learning_log>" >> /home1/irteam/apps/apache2/conf/httpd.conf
echo "<Files wsgi.py>" >> /home1/irteam/apps/apache2/conf/httpd.conf
echo "Order deny,allow" >> /home1/irteam/apps/apache2/conf/httpd.conf
echo "Require all granted" >> /home1/irteam/apps/apache2/conf/httpd.conf
echo "</Files>" >> /home1/irteam/apps/apache2/conf/httpd.conf
echo "</Directory>" >> /home1/irteam/apps/apache2/conf/httpd.conf

#DB 생성해봅시다
# useradd -M mysql -u 27 >& /dev/null
# chown -R root:mysql /home1/irteam/apps/mysql
cd /home1/irteam/apps/mysql


echo "[client]" > /etc/my.cnf
echo "default-character-set = utf8" >> /etc/my.cnf
echo "port = 3306" >> /etc/my.cnf
echo "socket = /tmp/mysql.sock" >> /etc/my.cnf
echo "default-character-set = utf8" >> /etc/my.cnf
echo "[mysqld]" >> /etc/my.cnf
echo "socket=/tmp/mysql.sock" >> /etc/my.cnf
echo "datadir=/home1/irteam/apps/mysql_data" >> /etc/my.cnf
echo "basedir = /home1/irteam/apps/mysql" >> /etc/my.cnf
echo "port = 3306" >> /etc/my.cnf
echo "skip-external-locking" >> /etc/my.cnf
echo "skip-grant-tables" >> /etc/my.cnf
echo "key_buffer_size = 384M" >> /etc/my.cnf
echo "max_allowed_packet = 1M" >> /etc/my.cnf
echo "table_open_cache = 512" >> /etc/my.cnf
echo "sort_buffer_size = 2M" >> /etc/my.cnf
echo "read_buffer_size = 2M" >> /etc/my.cnf
echo "read_rnd_buffer_size = 8M" >> /etc/my.cnf
echo "myisam_sort_buffer_size = 64M" >> /etc/my.cnf
echo "thread_cache_size = 8" >> /etc/my.cnf
echo "query_cache_size = 32M" >> /etc/my.cnf
echo "skip-name-resolve" >> /etc/my.cnf
echo "max_connections = 1000" >> /etc/my.cnf
echo "max_connect_errors = 1000" >> /etc/my.cnf
echo "wait_timeout= 60" >> /etc/my.cnf
echo "explicit_defaults_for_timestamp" >> /etc/my.cnf
echo "symbolic-links=0" >> /etc/my.cnf
echo "log-error=/home1/irteam/apps/mysql_data/mysqld.log" >> /etc/my.cnf
echo "pid-file=/tmp/mysqld.pid" >> /etc/my.cnf
echo "character-set-client-handshake=FALSE" >> /etc/my.cnf
echo "init_connect = SET collation_connection = utf8_general_ci" >> /etc/my.cnf
echo "init_connect = SET NAMES utf8" >> /etc/my.cnf
echo "character-set-server = utf8" >> /etc/my.cnf
echo "collation-server = utf8_general_ci" >> /etc/my.cnf
echo "symbolic-links=0" >> /etc/my.cnf
echo " " >> /etc/my.cnf
echo "key_buffer_size = 32M" >> /etc/my.cnf
echo "bulk_insert_buffer_size = 64M" >> /etc/my.cnf
echo "myisam_sort_buffer_size = 128M" >> /etc/my.cnf
echo "myisam_max_sort_file_size = 10G" >> /etc/my.cnf
echo "myisam_repair_threads = 1" >> /etc/my.cnf
echo " " >> /etc/my.cnf
echo "default-storage-engine = InnoDB" >> /etc/my.cnf
echo "innodb_buffer_pool_size = 1024MB" >> /etc/my.cnf
echo "innodb_data_file_path = ibdata1:10M:autoextend" >> /etc/my.cnf
echo "innodb_write_io_threads = 8" >> /etc/my.cnf
echo "innodb_read_io_threads = 8" >> /etc/my.cnf
echo "innodb_thread_concurrency = 16" >> /etc/my.cnf
echo "innodb_flush_log_at_trx_commit = 1" >> /etc/my.cnf
echo "innodb_log_buffer_size = 8M" >> /etc/my.cnf
echo "innodb_log_file_size = 128M" >> /etc/my.cnf
echo "innodb_log_files_in_group = 3" >> /etc/my.cnf
echo "innodb_max_dirty_pages_pct = 90" >> /etc/my.cnf
echo "innodb_lock_wait_timeout = 120" >> /etc/my.cnf
echo " " >> /etc/my.cnf
echo "[mysqldump]" >> /etc/my.cnf
echo "default-character-set = utf8" >> /etc/my.cnf
echo "max_allowed_packet = 16M" >> /etc/my.cnf
echo " " >> /etc/my.cnf
echo "[mysql]" >> /etc/my.cnf
echo "no-auto-rehash" >> /etc/my.cnf
echo "default-character-set = utf8" >> /etc/my.cnf
echo " " >> /etc/my.cnf
echo "[myisamchk]" >> /etc/my.cnf
echo "key_buffer_size = 256M" >> /etc/my.cnf
echo "sort_buffer_size = 256M" >> /etc/my.cnf
echo "read_buffer = 2M" >> /etc/my.cnf
echo "write_buffer = 2M" >> /etc/my.cnf

./bin/mysqld --initialize --user=mysql --basedir=/home1/irteam/apps/mysql --datadir=/home1/irteam/apps/mysql_data
#  ./support-files/mysql.server start

/home1/irteam/apps/mysql/support-files/mysql.server start &&\
./bin/mysql -e "create database django;" &&\
./bin/mysql -e "use mysql; update user set authentication_string=password('root') where user='root';"&&\
/home1/irteam/apps/mysql/bin/mysql -e "insert into mysql.user(host,user,authentication_string,ssl_cipher,x509_issuer,x509_subject) values('%','root',password('root'),'','','');" &&\
#/home1/irteam/apps/mysql/bin/mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'" &&\
/home1/irteam/apps/mysql/bin/mysql -e "flush privileges;"


sed -i 's/skip-grant-tables/#skip-grant-tables/g' /etc/my.cnf
./support-files/mysql.server restart
#  ./support-files/mysql.server restart &&\
#./bin/mysql -u root -pMyNewPass -e "use mysql; set password=password('root');"


cd /home1/irteam/apps/web_root/Django
sed -i "s/localhost/`hostname -I|cut -f 1 -d ' ' `/g" /home1/irteam/apps/web_root/Django/learning_log/settings.py
sed -i "s/13306/3306/g" /home1/irteam/apps/web_root/Django/learning_log/settings.py

echo "/home1/irteam/apps/mysql/support-files/mysql.server restart" >> /home1/irteam/apps/init_config
echo "/home1/irteam/apps/mysql/bin/mysql -u root -proot -e 'set password=password('root');'" >> /home1/irteam/apps/init_config
echo "/home1/irteam/apps/mysql/bin/mysql -u root -proot -e 'set password for 'root'@'%'=password('root');'" >> /home1/irteam/apps/init_config
echo "/home1/irteam/apps/mysql/bin/mysql -u root -proot -e 'GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'; flush privileges;'" >> /home1/irteam/apps/init_config
echo "/home1/irteam/apps/Python3/bin/python3 manage.py makemigrations" >> /home1/irteam/apps/init_config
echo "/home1/irteam/apps/Python3/bin/python3 manage.py migrate" >> /home1/irteam/apps/init_config

chmod +x /home1/irteam/apps/init_config
#  /home1/irteam/apps/init_config

echo "alias apachectl='/home1/irteam/apps/apache2/bin/apachectl'" >> ~/.bashrc
echo "alias mysql_service='/home1/irteam/apps/mysql/support-files/mysql.server'" >> ~/.bashrc
echo "alias mysql='/home1/irteam/apps/mysql/bin/mysql'" >> ~/.bashrc
