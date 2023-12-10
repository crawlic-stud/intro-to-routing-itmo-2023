- University: [ITMO University](https://itmo.ru/ru/)
- Faculty: [FICT](https://fict.itmo.ru)
- Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
- Year: 2023/2024
- Group: K33212
- Author: Kuznetsov Nikita Sergeevich
- Lab: Lab3
- Date of create: 01.12.2023
- Date of finished: 09.12.2023

# Отчет по лабораторной работе №3 "Эмуляция распределенной корпоративной сети связи, настройка OSPF и MPLS, организация первого EoMPLS"

## Цель работы

Изучить протоколы OSPF и MPLS, механизмы организации EoMPLS.

## Ход работы

### Описание задания:

Наша компания "RogaIKopita Games" с прошлой лабораторной работы выросла до серьезного игрового концерна, ещё немного и они выпустят свой ответ Genshin Impact - Allmoney Impact. И вот для этой задачи они купили небольшую, но очень старую студию "Old Games" из Нью Йорка, при поглощении выяснилось что у этой студии много наработок в области компьютерной графики и совет директоров "RogaIKopita Games" решил взять эти наработки на вооружение. К сожалению исходники лежат на сервере "SGI Prism", в Нью-Йоркском офисе никто им пользоваться не умеет, а из-за короновируса сотрудники офиса из Санкт-Петерубурга не могут добраться в Нью-Йорк, чтобы забрать данные из "SGI Prism". Ваша задача подключить Нью-Йоркский офис к общей IP/MPLS сети и организовать EoMPLS между "SGI Prism" и компьютером инженеров в Санк-Петербурге.

По заданию примерная схема сети выглядит следующим образом:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/344e1661-f570-4f3b-8836-9f1b63f51759)


Для того, чтобы реализовать данную сеть в ```containerlab``` был создан YAML файл следующего вида:

```yaml
name: lab3

mgmt:
  network: static
  ipv4-subnet: 172.20.23.0/24

topology:
  nodes:
    R01.NY:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.23.11
    R01.LND:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.23.12
    R01.LBN:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.23.13
    R01.HKI:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.23.14
    R01.MSK:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.23.15
    R01.SPB:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.23.16
    SGI_Prism:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.23.17
    PC1:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.23.18
  links:
    - endpoints: ["R01.NY:eth1", "SGI_Prism:eth1"]
    - endpoints: ["R01.NY:eth2", "R01.LND:eth1"]
    - endpoints: ["R01.NY:eth3", "R01.LBN:eth1"]
    - endpoints: ["R01.LND:eth2", "R01.HKI:eth1"]
    - endpoints: ["R01.LBN:eth2", "R01.MSK:eth1"]
    - endpoints: ["R01.LBN:eth3", "R01.HKI:eth3"]
    - endpoints: ["R01.HKI:eth2", "R01.SPB:eth2"]
    - endpoints: ["R01.MSK:eth2", "R01.SPB:eth1"]
    - endpoints: ["R01.SPB:eth3", "PC1:eth1"]
```
После деплоя лабораторной работы, репрезентация через ```containerlab graph``` выглядела следующим образом:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/b836dd93-743e-4b27-8843-a5dd0469cb96)

Далее, необходимо было настроить сеть, состояющую из:
 - 2 конечных устройств
 - 2 пограничных роутера с EoMPLS
 - 4 промежуточных роутера с MPLS

Внутрення маршрутизация будет проводиться по OSPF и MPLS. Сначала, рассмотрим настройку с роутера R01.NY (полные тексты скриптов настроек можно найти в директории /scripts).

### Настройка R01.NY

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/72bc42e2-df18-4cd1-b6d8-745f3818537b)

Здесь происходят следующие действия:

1. Добавление loopback интерфейса для обеспечения бесперебойной работы OSPF и MPLS. 
1. Включение MPLS и добавление интерфейсов ```eth3``` и ```eth4```
1. Конфигурация EoMPLS для устройства SGI Prism через добавление на интерфейсы ```bridge``` и ```eth2```, где:
   - cisco-style=yes - флаг указывает на то, что id будет указан так, как это делается на устройствах cisco
   - cisco-style-id=222 - id vpls интерфейса. Он должен быть одинаковым у соединяемых vpls интерфейсов
   - disabled=no - флаг включения/выключения интерфейса
   - name=EoMPLS - название интерфейса
   - remote-peer=10.10.10.6 - ip адрес, который был указан у второго устройства в поле transport-address

### Настройка R01.LND

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/96c32369-9386-46f0-b50f-242d026f01da)

### Настройка R01.LBN

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/1c5c8062-75fc-4b14-94c9-8752483419f9)

### Настройка R01.HKI

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/e6b7dda9-02fe-4086-9fd6-a9567577279f)

### Настройка R01.MSK

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/e2b43a0a-7398-4f61-88ed-d3f0e48fd22b)

### Настройка R01.SPB

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/82f73c94-ffbd-4b67-9dfc-e767a33f9b97)

### Настройка SGI_Prism

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/c5a752e8-73d1-4748-b0e1-65d33e82d7d2)

### Настройка PC1

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/a3c5e97f-1619-4f69-94e4-bd3d9084bdaf)

## Проверка

### Результат конфигурации MPLS

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/6982524c-871a-42d0-9c65-4b8f0b0fbad0)

Здесь можно заметить все интерфейсы (```INTERFACE```) и адреса (```DESTINATION```), которые были настроены ранее. 

### Проверка пингов от PC1 до SGI Prism:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/594614d5-27cf-459a-a525-47cc233d374f)

### Таблица маршрутизации для PC1 и SGI Prism

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/19f4d53b-41a9-4787-8501-381494682dad)

### Трассировка от R01.SPB до R01.NY

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/14f8def0-316f-4639-aaff-20fe12bc043c)


