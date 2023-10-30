 - University: [ITMO University](https://itmo.ru/ru/)
 - Faculty: [FICT](https://fict.itmo.ru)
 - Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
 - Year: 2023/2024
 - Group: K33212
 - Author: Kuznetsov Nikita Sergeevich
 - Lab: Lab1
 - Date of create: 29.10.2023
 - Date of finished: 29.10.2023

# Отчет по лабораторной работе №1 "Установка ContainerLab и развертывание тестовой сети связи"

## Цель работы

Научиться пользоваться ```containerlab```, реализовать базовую сеть из роутера, трех маршрутизаторов и двух ПК, а также провести их конфигурацию и проверить работоспособность.

## Ход работы

В начале работы были установлены нужные программы, в том числе репозиторий с образами routeros для docker и также программа containerlab.

![Установленные образы docker](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/47685b26-5ca2-41e1-834e-3e825e3096ab)

Затем, был создан файл для containerlab с базовой коммутацией двух ПК, как было показано на схеме:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/bf45b12f-b333-4e00-9745-a95269a1c545)

### Код для маршрутизации первой лабораторной работы:

```yml
name: lab1

topology:
  nodes:
    R01:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.1.2
      
    SW01.L3.01:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.1.5

    SW02.L3.01:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.1.6

    SW02.L3.02:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.1.7

    PC1:
      kind: linux
      image: ubuntu:latest
      mgmt-ipv4: 192.168.1.3

    PC2:
      kind: linux
      image: ubuntu:latest
      mgmt-ipv4: 192.168.1.4

  links:
      - endpoints: ["R01:eth1", "SW01.L3.01:eth1"]
      - endpoints: ["SW01.L3.01:eth2", "SW02.L3.01:eth1"]
      - endpoints: ["SW02.L3.01:eth2", "PC1:eth1"]
      - endpoints: ["SW01.L3.01:eth3", "SW02.L3.02:eth1"]
      - endpoints: ["SW02.L3.02:eth2", "PC2:eth1"]
      
mgmt:
  network: static
  ipv4-subnet: 192.168.1.0/24
```

Запустить данный код можно с помощью команды ```sudo containerlab deploy lab1.clab.yml```, в результате чего всё успешно проходит и выводится информация о запущенных контейнерах:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/741cc2a8-0642-4dd0-b1ad-f889c6b0cd66)

Также, можно посмотреть получившуюся схему от containerlab, используя команду ```sudo containerlab graph```, и сравнить её с схемой, нарисованной выше от руки:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/5f848448-a6e3-45ce-be4f-4c755668a23e)

Как можно заметить, схемы по своей сути идентичны.

Далее, необходимо провести конфигурацию каждого из устройств (роутер и три свитча). Для этого необходимо зайти в командный интерфейс контейнера через ```telnet <container ip>```:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/eb2d02d5-87f6-416b-b2a1-62941e7f454d)

### Конфигурация R01:

Для роутера: 
 - Создаются два vlan на интерфейсе ether2
 - Изменяется идентификатор для беспроводных сетей, это нужно для идентификации устройства в Wi-Fi
 - Создаются два пула адресов, предназначенные для выдачи адресов в vlan10 и vlan20
 - Создаются два dhcp сервера
 - Задаются адреса для ether1 и vlan10/20
 - Добавляются настройки для установки шлюзов в dhcp сервере 

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/4181beee-23f2-497f-9975-dadc4bc52d0a)


### Конфигурация SW01.L3.01

Для маршрутизаторов:
 - Создается мост (bridge) для объединения vlanов
 - Добавляются интерфейсы vlan в соответствущие мосты
 - Включается dhcp клиент на интерфейсе ether1, что позволит автоматически настраивать конфигурацию через dhcp-сервер


![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/99d7eb71-b4f1-43eb-bf6d-6fd452771fed)


### Конфигурация SW02.L3.01

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/b9a7d2da-9e3c-4d9b-a13d-1ef63e002ed1)


### Конфигурация SW02.L3.02

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/cf76904c-fd33-4e40-bf5c-9da5dc7d21c2)

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/ea308c0f-90db-452b-b8bf-a7291ff1c6e2)


### Проверка доступности

Для проверки доступности можно посмотреть таблицу DHCP у роутера R01. В ней можно увидеть 4 айпи, можно пропинговать один из них, например: ```172.20.20.254```

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/a3d95de4-c66d-4a2f-a328-8da8bfe3b12d)

Аналогично можно проверить с другими адресами:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/ef38b6c4-c52f-49ba-92a0-0d08251307fa)


## Вывод

В результате работы была построена базовая сеть, состоящая из трех маршрутизаторов, роутера и двух ПК. Были настроены адреса интерфейсов, VLANы, мосты и настроен DHCP-сервер, который назначил автоматические адреса устройствам. В результате работы было успешно проверено соединение между выданными IP через команду ping.


