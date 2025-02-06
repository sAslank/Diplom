#  Дипломная работа по профессии «`Системный администратор`» - Кумышев Аслан-SYS-32

## Инфраструктура

Для развертки инфраструктуры были использованы Terraform и Ansible.
На локальный хост для удобства был установлен Visual studio code.
Для подключения с локального хоста к сервису Yandex Cloud был создан файл .terraformrc и размещен в домашней директории. 

скрин

Далее произвел установку CLI для управления ресурсами Yandex Cloud. Командой : curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash.

Настроил файлы авторизации для сервиса Yandex Cloud:  terraform.tfvars, variables.tf.


Поднял Виртуальные машины main.tf.

скрин



Сеть

Были настроены подсети:
subnet-private1 - Vm1 // Зона А
subnet-private2 - Vm2 // Зона B
subnet-private3 - Elasticsearch // Зона А
subnet-public1 - Kibana, Zabbix, Bastion,LB // Зона А

скрин


Так же была поднята сеть Security Groups соответствующих сервисов на входящий трафик к нужным портам.


скрин


Произвел настройку балансировщика:

Target Group и вкл в неё две созданные вм

скрин

Создал Backend Group настроил backends на target group, раннее созданную. Настроил healthcheck на корень (/) и порт 80, протокол HTTP.

скрин

Создал HTTP router указав путь (/) на backend group

скрин

Создал ALB для распределения трафика на веб-сервера, созданные ранее. Указал HTTP router, созданный ранее, задав listener тип auto, порт 80.


скрин

Протестировал сайт curl -v                              :80

скрин




Сайт


Ansible 

Установил ansible на локальном хосте где работали с terraform и настроил его на работу через bastion.

ansible.cfg выглядит следующим образом:

скрин 



Был создан файл hosts.cfg который был непосредственно подвязан к шаблону hosts.tpl для более быстрой автоматизации, были заменены ip-адреса, вместо этого использовал FQDN как и требовалось по условию. Так же были созданы  RSA-ключи и подвязаны ко всем ВМ открыв доступ chmod 600 id_rsa*


скрин

Настроил ssh config проходить через Bastion.

скрин

Проверил пинг всех созданных хостов.


скрин


Установил Nginx на ВМ1 и ВМ2. Использовав плейбук nginx.yml
Проверил доступность Web страниц с Вм1 и Вм2, а так же проверил доступность сайта в браузере по публичному ip адресу Load Balancer.

скрин

скрин

скрин


Мониторинг

Создал базу данных PostgreSQL с помощью плейбука psql.yml
 
скрин

Установил Zabbix агенты на web сервера с заменой конфигурации zabbix_agentd.conf.

скрин

Проверил статус служб Zabbix agent на Web серверах

скрин

Поставил Zabbix-Server с файлом конфигурации zabbix_server.conf. Зашел с локального хоста по ssh на Zabbix и прописал схему и перезагрузил сервисы:

zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | psql zabbix_db
systemctl restart zabbix-server zabbix-agent apache2 



Доступ открыт по адресу: 

Логин: Admin
Пароль: zabbix

скрин

Логи

С помощью Ansible разворачиваю Elasticsearch используя плейбук elasticsearch.yml с правкой конфигурации elasticsearch.yml

Проверка с ВМ Elasticsearch: curl -XGET 'localhost:9200/_cluster/health?pretty'

скрин



Установил Filebeat в ВМ к веб-серверам, настроил отправку логов Nginx в Elasticsearch. Файл конфигурации: 

скрин

Далее разворачиваю Kibana и конфигурирую соединение с Elasticsearch. Файл конфигурации: 

скрин

Доступ к web Elasticsearch открыт по адресу: http://158.160.168.121:5601/login/


скрин


Логи подтянулись, filebeat работает корректно.

скрин

Резервное копирование 

Резервное копирование настроено через snapshots.tf , на ежедневные снимки, с хранением на 7 дней.

скрин

END.
