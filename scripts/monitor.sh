#!/bin/bash

REPORT="../reports/health_report.log"
ALERT="../reports/alerts.log"
LOGS="../logs/system_logs.log"

echo "=============================================">>$REPORT
echo "Server Health Report">>$REPORT
echo "Date :$(date)">>$REPORT
echo "=============================================">>$REPORT

echo " ">>$REPORT

echo "CPU Usage">>$REPORT

top -bn1 | grep "Cpu(s)">>$REPORT

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
echo "CPU Usage : $CPU %">>$REPORT


echo "Memory Usage">>$REPORT
free -h >>$REPORT

MEMORY=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2*100}')
echo "Memory Usage : $MEMORY %" >>$REPORT

echo " ">>$REPORT


echo "Disk Usage" >>$REPORT
df -h >>$REPORT

DISK=$(df | awk 'END{print $5}' | sed 's/%//')

echo "Disk Usage :$DISK %">>$REPORT


if [ $DISK -gt 80 ]
then
	echo "ALert : Disk Usage Greater than 80%" >>$ALERT
fi

echo " ">>$REPORT


echo "Running Services">>$REPORT

systemctl list-units --type=service --state=running >>$REPORT

STATUS=$(systemctl is-active apache2)

if [ "$STATUS" != "active" ]
then
echo "$(date) ALERT : Apache is Down" >>$ALERT
fi

echo "=======Service Status=======" >>$REPORT

SERVICES=("apache2" "nginx" "jenkins" "docker" "mysql")

for SERVICE in "${SERVICES[@]}"
do
	CHECK=$(systemctl is-active "$SERVICE" 2>/dev/null)
	echo "$SERVICE : $CHECK" >>$REPORT
	
	if [ "$CHECK" != "active" ]
	then
		echo "$(date) ALERTed: $SERVICE is Down" >>$ALERT
	fi
done

echo " ">>$REPORT

echo "Running Process" >>$REPORT

ps -ef | head >>$REPORT

echo "Collecting System Logs....." >> $REPORT

journalctl -n 100 > $LOGS

echo "System logs are saved to logs folder">>$REPORT


echo " ">>$REPORT

echo "=====================================================================" >>$REPORT
