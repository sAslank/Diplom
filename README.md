#  Дипломная работа по профессии «Системный администратор» - `Кумышев Аслан SYS-32`

# Инфраструктура

## Для развертки инфраструктуры были использованы Terraform и Ansible.
На локальный хост для удобства был установлен Visual studio code.
Для подключения с локального хоста к сервису Yandex Cloud был создан файл .terraformrc и размещен в домашней директории. 

![alt text](https://github.com/sAslank/Diplom/blob/main/img/1.jpg)

Далее произвел установку CLI для управления ресурсами Yandex Cloud. Командой : 

```
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash.
```

Настроил файлы авторизации для сервиса Yandex Cloud: main.tf, variables.tf.


Поднял Виртуальные машины main.tf.

![alt text](https://github.com/sAslank/Diplom/blob/main/img/2.jpg)



# Сеть

Были настроены подсети:

subnet-private1 - Vm1 // Зона А

subnet-private2 - Vm2 // Зона B

subnet-private3 - Elasticsearch // Зона А

subnet-public1 - Kibana, Zabbix, Bastion,LB // Зона А


![alt text](https://github.com/sAslank/Diplom/blob/main/img/3.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/4.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/5.jpg)

Так же была поднята сеть Security Groups соответствующих сервисов на входящий трафик к нужным портам.

![alt text](https://github.com/sAslank/Diplom/blob/main/img/10.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/11.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/12.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/10.jpg)

Произвел настройку балансировщика:

Target Group и вкл в неё две созданные вм

![alt text](https://github.com/sAslank/Diplom/blob/main/img/9.jpg)

Создал Backend Group настроил backends на target group, раннее созданную. Настроил healthcheck на корень (/) и порт 80, протокол HTTP.

![alt text](https://github.com/sAslank/Diplom/blob/main/img/b.jpg)

Создал HTTP router указав путь (/) на backend group

![alt text](https://github.com/sAslank/Diplom/blob/main/img/7.jpg)

Создал ALB для распределения трафика на веб-сервера, созданные ранее. Указал HTTP router, созданный ранее, задав listener тип auto, порт 80.


![alt text](https://github.com/sAslank/Diplom/blob/main/img/6.jpg)


# Сайт


## Ansible 

Установил ansible на локальном хосте где работали с terraform и настроил его на работу через bastion.

ansible.cfg выглядит следующим образом:

![alt text](https://github.com/sAslank/Diplom/blob/main/img/14.jpg)



Был создан файл hosts.cfg который был непосредственно подвязан к шаблону hosts.tpl для более быстрой автоматизации, были заменены ip-адреса, вместо этого использовал FQDN как и требовалось по условию. Так же были созданы  RSA-ключи и подвязаны ко всем ВМ открыв доступ chmod 600 id_rsa*


![alt text](https://github.com/sAslank/Diplom/blob/main/img/15.jpg)

Настроил ssh config проходить через Bastion. По пути ~/.ssh/config

![alt text](https://github.com/sAslank/Diplom/blob/main/img/16.jpg)

Сбросил старые ключи 
```
sudo rm -f /home/fox/.ssh/known_hosts, sudo rm -f /home/fox/.ssh/known_hosts.old.
```
Проверил пинг всех созданных хостов.

![alt text](https://github.com/sAslank/Diplom/blob/main/img/17.jpg)


Установил Nginx на ВМ1 и ВМ2. Использовав плейбук nginx.yml
Проверил доступность Web страниц с Вм1 и Вм2, а так же проверил доступность сайта в браузере по публичному ip адресу Load Balancer.

![alt text](https://github.com/sAslank/Diplom/blob/main/img/18.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/19.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/20.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/21.jpg)


# Мониторинг

Создал базу данных PostgreSQL с помощью плейбука psql.yml.

```ansible-playbook zabbix_agent.yml -i hosts.cfg``` 

![alt text](https://github.com/sAslank/Diplom/blob/main/img/22.jpg)

Установил Zabbix агенты на web сервера с заменой конфигурации zabbix_agentd.conf. 

```ansible-playbook zabbix_agent.yml -i hosts.cfg```

![alt text](https://github.com/sAslank/Diplom/blob/main/img/23.jpg)

Проверил статус служб Zabbix agent на Web серверах

![alt text](https://github.com/sAslank/Diplom/blob/main/img/24.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/25.jpg)

Поставил Zabbix-Server с файлом конфигурации zabbix_server.conf. 

```ansible-playbook zabbix_server.yml -i hosts.cfg ```

Зашел с локального хоста по ssh на Zabbix и прописал схему и перезагрузил сервисы:

```zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | psql zabbix_db``` 
``` systemctl restart zabbix-server zabbix-agent apache2``` 

![alt text](https://github.com/sAslank/Diplom/blob/main/img/26.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/27.jpg)

Доступ открыт по адресу: http://84.252.129.37/zabbix/

Логин: Admin
Пароль: zabbix

![alt text](https://github.com/sAslank/Diplom/blob/main/img/28.jpg)

При возниковении сложности подключения сервера, один из вариантов решения добавить его вручную на самом сервере и перезапустить сервис.

![alt text](https://github.com/sAslank/Diplom/blob/main/img/29.jpg)

ВМ подключены

![alt text](https://github.com/sAslank/Diplom/blob/main/img/el.jpg)


Настроил дашборды с отображением метрик.

![alt text](https://github.com/sAslank/Diplom/blob/main/img/38.jpg)



# Логи

С помощью Ansible разворачиваю Elasticsearch используя плейбук elasticsearch.yml с правкой конфигурации elasticsearch.yml

![alt text](https://github.com/sAslank/Diplom/blob/main/img/31.jpg)

Проверка с ВМ Elasticsearch: ```curl -XGET 'localhost:9200/_cluster/health?pretty'```

![alt text](https://github.com/sAslank/Diplom/blob/main/img/32.jpg)



Установил Filebeat в ВМ к веб-серверам, настроил отправку логов Nginx в Elasticsearch. Файл конфигурации: 

![alt text](https://github.com/sAslank/Diplom/blob/main/img/33.jpg)

Далее разворачиваю Kibana и конфигурирую соединение с Elasticsearch. Файл конфигурации: 

![alt text](https://github.com/sAslank/Diplom/blob/main/img/34.jpg)

Доступ к web Elasticsearch открыт по адресу: http://51.250.83.79:5601/login/


Логи подтянулись, filebeat работает корректно.

![alt text](https://github.com/sAslank/Diplom/blob/main/img/35.jpg)

![alt text](https://github.com/sAslank/Diplom/blob/main/img/36.jpg)


# Резервное копирование 

Резервное копирование настроено через snapshots.tf , на ежедневные снимки к 6 часам, с хранением на 7 дней.

![alt text](https://github.com/sAslank/Diplom/blob/main/img/37.jpg)

# END.
