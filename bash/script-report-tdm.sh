#!/bin/bash

dateNew=$(date "+%F")
dateOld=$(date "+%F"  --date="1 day ago")
date2dayAgo=$(date "+%F"  --date="2 day ago")
dateFuture=$(date --date="12/31/2025" "+%F")
echo "select " > /home/ubuntu/daily-report-/kalendar.txt
echo "select " > /home/ubuntu/daily-report-/active-user.txt

sleep 1
activeUser=$(cat /home/ubuntu/daily-report-/active-user.txt)
userByEmployee=$(cat /home/ubuntu/daily-report-/user-by-employee.txt)
userByOrg=$(cat /home/ubuntu/daily-report-/user-by-organization.txt)
kalendar=$(cat /home/ubuntu/daily-report-/kalendar.txt)
/opt/bin/kubectl exec -ti -n   postgres--main-0  -c postgres -- psql -U postgres -d name -c "$activeUser"
sleep 1
/opt/bin/kubectl exec -ti -n   postgres--main-0  -c postgres -- psql -U postgres -d name -c "$userByEmployee"
sleep 1
/opt/bin/kubectl exec -ti -n   postgres--main-0  -c postgres -- psql -U postgres -d name -c "$userByOrg"
sleep 1
/opt/bin/kubectl cp /postgres--main-0:/tmp/active-users-by-organization.csv  /home/ubuntu/daily-report-/report/active-users-by-organization.csv
sleep 1
/opt/bin/kubectl cp /postgres--main-0:/tmp/users-by-employee.csv  /home/ubuntu/daily-report-/report/users-by-employee.csv
sleep 1
/opt/bin/kubectl cp /postgres--main-0:/tmp/users-by-organization.csv  /home/ubuntu/daily-report-/report/users-by-organization.csv
sleep 1
/opt/bin/kubectl exec -ti -n   postgres--main-0  -c postgres -- psql -U postgres -d name -c "$kalendar" -n -o /tmp/kalendar.csv
sleep 1
/opt/bin/kubectl cp /postgres--main-0:/tmp/kalendar.csv  /home/ubuntu/daily-report-/report/date.csv
sleep 2
curl -v -F "chat_id=-12" -F document=@/home/ubuntu/daily-report-/report/date.csv https://api.telegram.org/1/sendDocument
curl -v -F "chat_id=-12" -F document=@/home/ubuntu/daily-report-/report/users-by-organization.csv https://api.telegram.org/1/sendDocument
curl -v -F "chat_id=-12" -F document=@/home/ubuntu/daily-report-/report/users-by-employee.csv https://api.telegram.org/1/sendDocument
curl -v -F "chat_id=-12" -F document=@/home/ubuntu/daily-report-/report/active-users-by-organization.csv https://api.telegram.org/1/sendDocument
