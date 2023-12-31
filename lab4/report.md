- University: [ITMO University](https://itmo.ru/ru/)
- Faculty: [FICT](https://fict.itmo.ru)
- Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
- Year: 2023/2024
- Group: K33212
- Author: Kuznetsov Nikita Sergeevich
- Lab: Lab4
- Date of create: 09.12.2023
- Date of finished: 17.12.2023

# Отчет по лабораторной работе №4 "Эмуляция распределенной корпоративной сети связи, настройка iBGP, организация L3VPN, VPLS"

## Цель работы

Изучить протоколы BGP, MPLS и правила организации L3VPN и VPLS.

## Ход работы

### Описание задания:

Компания "RogaIKopita Games" выпустила игру "Allmoney Impact", нагрузка на арендные сервера возрасли и вам поставлена задача стать LIR и организовать свою AS чтобы перенести все сервера игры на свою инфраструктуру. После организации вашей AS коллеги из отдела DEVOPS попросили вас сделать L3VPN между 3 офисами для служебных нужд. (Рисунок 1) Данный L3VPN проработал пару недель и коллеги из отдела DEVOPS попросили вас сделать VPLS для служебных нужд.

По заданию примерная схема сети выглядит следующим образом:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/cc850d71-7112-4a9c-a46e-e4dc5a27fc3d)

Чтобы реализовать данную схему в ```containerlab``` была составлена следующая топология:

```yaml
name: lab4

mgmt:
  network: statics4
  ipv4-subnet: 192.168.20.0/24

topology:
  
  nodes:
    R01.NY: 
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9 
      mgmt-ipv4: 192.168.20.12

    R01.LND:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.20.13

    R01.HKI:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.20.14

    R01.SPB:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.20.15

    R01.LBN:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.20.16
    
    R01.SVL:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.20.17

    PC1:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.20.18
    
    PC2:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.20.19

    PC3:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 192.168.20.20

  links:
    - endpoints: ["PC1:eth1","R01.SPB:eth2"]
    - endpoints: ["PC2:eth1","R01.NY:eth1"]
    - endpoints: ["PC3:eth1","R01.SVL:eth2"]
    - endpoints: ["R01.NY:eth2","R01.LND:eth1"]
    - endpoints: ["R01.LND:eth2","R01.HKI:eth1"]
    - endpoints: ["R01.LND:eth3","R01.LBN:eth1"]
    - endpoints: ["R01.HKI:eth2","R01.SPB:eth1"]
    - endpoints: ["R01.HKI:eth3","R01.LBN:eth2"]
    - endpoints: ["R01.LBN:eth3","R01.SVL:eth1"]
```

Далее, данная сеть была запущена и был выведен следующий граф с помощью команды ```containerlab graph```:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/3112e018-3c4d-461e-86ed-6b59ee2da37f)

### 1 часть. Настройка VRF.

Для выполнения первой части задания был настроен каждый роутер (полные скрипты настроек можно посмотреть в папке ```/scripts```):

1. Конфигурация R01.NY:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/d26af662-404d-4c2a-8739-bc0c7c9d6490)

2. Конфигурация R01.LND:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/ce9ebca0-c4ab-424b-860c-3e3042b56c2a)

3. Конфигурация R01.HKI:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/a3ddb4e5-d6d3-44fd-9478-4d87d0bf42b2)

4. Конфигурация R01.SPB:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/78f2c53e-c8ff-4eab-ac15-2139680987fd)

5. Конфигурация R01.LBN:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/5288a813-fa2c-465c-bd4b-aabacffe8fee)

6. Конфигурация R01.SVL:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/04ef9bd6-5b48-4aac-966c-adffaad6a87b)

В целом, конфигурации похожи, в них можно обобщить следующие действия:

 - создается bridge Lo
 - настраивается BGP (Border Gateway Protocol), который устанавливает флаг перераспределения подключенных маршрутов и определяет идентификатор роутера
 - настраивается OSPF (Open Shortest Path First) по умолчанию
 - добавляются IP-адреса
 - включаются и настраиваются DHCP-клиенты
 - добавляются маршруты VRF (Virtual Routing and Forwarding) с экспортом и импортом маршрутных целей, интерфейсом ether2, идентификатором маршрутного отличителя и маршрутным отметкой
 - добавлются интерфейсы в MPLS
 - добавляется BGP VRF с перераспределением подключенных маршрутов и маршрутной отметкой
 - настраивается BGP "семья", адреса, номер и прочее.
 - настраивается OSPF сеть с backbone
 - устанавливается имя устройства

После всех настроек, можно просмотреть: 

1. Связность VRF с помощью команды ```routing bgp vpnv4-route print```:
 - для R01.NY:
   
![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/690cc3b9-e1a1-49f8-8523-bf4e8c298181)

 - для R01.SPB:
 
![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/65e1b41d-efc7-4f95-98fc-91a7bc28de0d)

 - для R01.SVL:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/5b1119d8-1cd4-407f-ab96-4d8a77b40945)
 
2. Таблицы маршрутизации в WEB-интерфейсе по адресу ```http://{mgmt-ip}/webfig```:
 - для R01.NY:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/836c8f91-41f2-4b56-876a-bd7118677c89)

 - для R01.SPB:
 
![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/78ece813-0b58-4ea5-a9d5-041d7215ebef)

 - для R01.SVL:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/2d38ba10-55a5-46b9-8c6f-751d72ce3192)

3. Проверку доступности через пинг, используя таблицу маршрутизации ```VRF_DEVOPS```:

 - для R01.NY:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/5abcd414-34fd-409d-b630-4d16aa8c812c)

 - для R01.SPB:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/41938ba1-f277-4ef1-ac0e-9783cb9d76e8)

 - для R01.SVL:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/b2ad770a-03a1-4076-a7a1-76da4f788606)


### 2 часть. Настройка VPLS.

В начеле, необходимо было базово настроить устройства PC, выдать адреса и включить DHCP:

- настройка PC1:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/4d46c320-2607-4a7e-8778-60bf4a51a951)

- настройка PC2:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/1be44a6c-c539-4f76-9165-ad05fe346203)

- настройка PC3:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/639a9bd3-db85-4476-8d80-a37364dd6b00)

Далее, необходимо было обновить конфигурацию роутеров NY, SPB и SVL. Ниже приведена конфигурация для R01.NY, полные конфигурации для SPB и SVL можно просмотреть в папке ```/scripts```:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/53588a71-1828-4af8-a06e-74354c498834)

В данной конфигурации происходит следующее (часть пунктов уже упомянута в описании предыдущей конфигурации):
- добавляется второй мост для VPLS
- создается VPLS туннели, связывающиеся с узлами через IP-адреса 4.4.4.4 и 6.6.6.6
- указываются MAC-адреса и идентификаторы VPLS
- устанавливается идентификатор роутера для BGP и OSPF
- добавляется пир BGP
- назначаются IP адреса для интерфейсов

После всех настроек, можно проверить доступность PC в сети:

1. пинг c PC1:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/1d62e4ef-ada7-418a-90a2-8c5148b1c61e)

2. пинг c PC2:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/83fd0a72-b3d5-4b1b-8174-b45ad08f0a58)

3. пинг c PC3:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/e49f163f-ab92-4a49-8805-8fe93f490f77)

Как можно заметить - устройства пингуются, а значит настройка проведена успешно.

## Вывод: 

В данной лабораторной работе, на праактике были изучены протоколы BGP, MPLS и правила организации L3VPN и VPLS.

