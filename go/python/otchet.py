import requests
import time

PROMETHEUS = 'urlprometheus'

MESSAGE = """
Текущий статус по работе
1. Утилизация ресурсов (%):  CPU-{}, Memory-{}, Storage-{}.
2. Суммарная загрузка на сетевых интерфейсах NetIn - {} Мбит/c , NetOut - {} Мбит/c.
3. Работа приложений сервера: аномалий не наблюдается, кластер работает в штатном режиме.
"""

dict_query = {
#cpu stat utilization
'cpu':'avg(100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100))',
#memory utilz
'memory':' node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100' ,
#filesystem stat utilizations
'fs':'(node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes  ',
#net incom utilz
'netin':'7*avg(rate(node_network_receive_bytes_total{device="internal"}[5m])*8)/1024/1024',
#net out
'netout':"7*avg(rate(node_network_transmit_bytes_total{device='internal'}[5m])*8)/1024/1024"
}

result = []

for key,query in dict_query.items():
    res = requests.get(PROMETHEUS + '/api/v1/query',auth=('admin', 'admin'), params={'query': query})
    value = res.json().get('data').get('result')[0].get('value')[1]
    result.append(round(float(value),1))

print(MESSAGE.format(*result))

# res = requests.get(f'https://api.telegram.org/token/sendMessage?chat_id=-10&text={MESSAGE.format(*result)}')
res = requests.get(f'https://api.telegram.org/token/sendMessage?chat_id=-10&text={MESSAGE.format(*result)}')

#time.sleep(1000)


