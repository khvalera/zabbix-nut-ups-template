#!/bin/sh

#yum -q list installed zabbix50  &>/dev/null
#if [ "$?" = 0 ]; then
#   yum erase zabbix50 zabbix50-agent
#fi
#yum -q list installed zabbix-agent  &>/dev/null
#if [ "$?" = 0 ]; then
#   yum erase zabbix-agent
#fi

yum -q list installed zabbix-agent2  &>/dev/null
if [ "$?" != 0 ]; then
   rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/7/x86_64/zabbix-agent2-6.4.6-release1.el7.x86_64.rpm
   #yum clean all
   #yum install zabbix-agent2
fi

name=`hostname -s`;
sed "s|Hostname=Zabbix server|Hostname=$name|" -i /etc/zabbix/zabbix_agent2.conf;

sed "s|LogFileSize=0|LogFileSize=1|" -i /etc/zabbix/zabbix_agent2.conf;
sed '/\# LogType=file/ a LogType=file' -i /etc/zabbix/zabbix_agent2.conf

wget https://raw.githubusercontent.com/khvalera/zabbix-nut-ups-template/master/zabbix-agent2/ups-data.sh -O ./ups-data.sh
wget https://raw.githubusercontent.com/khvalera/zabbix-nut-ups-template/master/zabbix-agent2/userparameter_nut.conf -O ./userparameter_nut.conf
wget https://raw.githubusercontent.com/khvalera/zabbix-nut-ups-template/master/zabbix-agent2/zabbix_agentd_psk.conf -O ./zabbix_agentd_psk.conf

install -m750 ups-data.sh /etc/zabbix/zabbix_agent2.d/ups-data.sh
install -m660 userparameter_nut.conf /etc/zabbix/zabbix_agent2.d/userparameter_nut.conf

chown "zabbix:zabbix" /etc/zabbix/zabbix_agent2.d/ups-data.sh
chown "zabbix:zabbix" /etc/zabbix/zabbix_agent2.d/userparameter_nut.conf

# Использование pre-shared (PSK) ключей
# https://www.zabbix.com/documentation/5.2/ru/manual/encryption/using_pre_shared_keys
openssl rand -hex 32 > /etc/zabbix/zabbix_agent2.d/zabbix_agentd.psk

chown "zabbix:zabbix" /etc/zabbix/zabbix_agent2.d/zabbix_agentd.psk
chmod 400 /etc/zabbix/zabbix_agent2.d/zabbix_agentd.psk

echo -e "\033[32mPSK:\033[39m"
echo $name;
cat  /etc/zabbix/zabbix_agent2.d/zabbix_agentd.psk

install -m660 zabbix_agentd_psk.conf /etc/zabbix/zabbix_agent2.d/zabbix_agentd_psk.conf
sed "s|TLSPSKIdentity=|TLSPSKIdentity=$name|" -i /etc/zabbix/zabbix_agent2.d/zabbix_agentd_psk.conf;
chown "zabbix:zabbix" /etc/zabbix/zabbix_agent2.d/zabbix_agentd_psk.conf;

systemctl restart zabbix-agent2.service
systemctl status zabbix-agent2.service
systemctl enable zabbix-agent2.service


