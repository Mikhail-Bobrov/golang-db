#CRITICAL CHAT
import email
from bs4 import BeautifulSoup
import requests
# account credentials
username = "user"
password = "passs"

# !/usr/bin/env python3
# -*- encoding: utf-8 -*-

import imaplib

mail = imaplib.IMAP4_SSL('mail.groupcompany.ru')
mail.login(username, password)

mail.list()
mail.select("inbox")
# create an IMAP4 class with SSL
imap = imaplib.IMAP4_SSL("mail.groupcompany.ru")
# authenticate
imap.login(username, password)

result, data = mail.search(None, "UNSEEN")

ids = data[0]
id_list = ids.split()
if id_list == []:
    quit()
latest_email_id = id_list[0]

result, data = mail.fetch(latest_email_id, "(RFC822)")
raw_email = data[0][1]
raw_email_string = raw_email.decode('utf-8')
email_message = email.message_from_string(raw_email_string)

if email_message.is_multipart():
    for payload in email_message.get_payload():
        body = payload.get_payload(decode=True).decode('utf-8')
        soup = BeautifulSoup(body, "lxml").prettify()
        #data1 = soup.find_all("a").text
        #data2 = soup.title()
        #print(data1)
else:
    body = email_message.get_payload(decode=True).decode('utf-8')
    soup1 = BeautifulSoup(body, "lxml")

    # template
    resolv_alert = soup1.find("title").text
    title = soup1.find("h1").text
    #Kubernetes Container - Memory limit utilization
    state1 = soup1.find("span").text.strip()
    #Alert firing
    link_alert1 = soup1.find("a").get("href")
    # link alert /VIEW INCIDENT
    alert_massive_all = soup1.find_all("p")
    value1 = alert_massive_all[0].text.replace("\n",": ")
    start_time = alert_massive_all[1].text.replace("\n",": ")
    # +++Start time
    project = alert_massive_all[2].text.replace("\n",": ")
    #----project    #### Alert firing lasted
    policy = alert_massive_all[3].text.replace("\n",":  ")
    condition = alert_massive_all[4].text.replace("\n",": ")
    #condition Kubernetes Container - Memory limit utilization
    text_condition_res = alert_massive_all[5].text.replace("\n",": ")
    ## for resolve condition
    threshold_limit = alert_massive_all[6].text.replace("\n",": ")
    # threshold
    threshold_now = alert_massive_all[7].text.replace("\n",": ")
    metric_label = alert_massive_all[8].text.replace("\n",": ")

    resolving_alert = "✅✅ RESOLVED ALERTS ✅✅"
    firing_alert = "🚨🚨 FIRING ALERTS 🚨🚨"
    if state1 == "Alert firing":
        final1 = firing_alert + "\n" + "💥💥💥" + resolv_alert + "💥💥💥" + "\n" + "🔹"+ project + "\n" + "🔹" + start_time + "\n" + "🔹" + condition + "\n" + "🔹" + policy + "\n" "🔹" + threshold_limit + "\n" + "🔹" + threshold_now + "\n" + "🔸 description: " + value1 + "\n" + "🔸 link: " + link_alert1
        str = requests.get(f"https://api.telegram.org/bot/sendMessage?chat_id=-1&text={final1}")
    else:
        final2 = resolving_alert + "\n" + "🟢🟢🟢"+ resolv_alert + "🟢🟢🟢" + "\n" + "🔹" + policy + "\n" + "🔹" +start_time + "\n" + "🔹" +text_condition_res + "\n" + "🔹" + condition + "\n" + "🔹" + threshold_now + "\n" + "🔹" + metric_label + "\n" + "🔸 description: " + value1 + "\n" + "🔸 link: " + link_alert1
        str = requests.get(f"https://api.telegram.org/bo/sendMessage?chat_id=-1&text={final2}")


