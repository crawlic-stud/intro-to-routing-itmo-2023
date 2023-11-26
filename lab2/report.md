- University: [ITMO University](https://itmo.ru/ru/)
- Faculty: [FICT](https://fict.itmo.ru)
- Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
- Year: 2023/2024
- Group: K33212
- Author: Kuznetsov Nikita Sergeevich
- Lab: Lab1
- Date of create: 19.11.2023
- Date of finished: 26.11.2023

# Отчет по лабораторной работе №2 "Эмуляция распределенной корпоративной сети связи, настройка статической маршрутизации между филиалами"

## Цель работы

Ознакомиться с принципами планирования IP адресов, настройке статической маршрутизации и сетевыми функциями устройств.

## Ход работы

По заданию необходимо было реализовать сеть для связи трех компьютеров в разных городах (Москве, Франкфурте и Берлине), примерная схема сети выглядит следующим образом:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/1e0c3399-a591-4ac1-b20f-0c8e5f114c52)

Для того, чтобы реализовать данную сеть в ```containerlab``` был создан YAML файл следующего вида:

```yaml
name: lab2

topology:
  nodes:
    R01.MSK:
      image: vrnetlab/vr-routeros:6.47.9
      kind: vr-ros
      mgmt-ipv4: 172.168.100.2

    R01.FRT:
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.168.100.3
      kind: vr-ros
    
    R01.BRL:
      image: vrnetlab/vr-routeros:6.47.9
      kind: vr-ros
      mgmt-ipv4: 172.168.100.4

    PC1.MSK:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.168.100.5

    PC2.FRT:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.168.100.6
    
    PC3.BRL:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.168.100.7

  links:
    - endpoints: ["R01.BRL:eth2", "R01.FRT:eth2"]
    - endpoints: ["R01.BRL:eth3", "R01.MSK:eth2"]
    - endpoints: ["R01.MSK:eth3", "R01.FRT:eth3"]
    - endpoints: ["R01.MSK:eth1", "PC1.MSK:eth1"]
    - endpoints: ["R01.FRT:eth1", "PC2.FRT:eth1"]
    - endpoints: ["R01.BRL:eth1", "PC3.BRL:eth1"]

mgmt:
  network: static
  ipv4-subnet: 172.168.100.0/24
```

## Настройка роутеров

После создания и запуска топологии через ```containerlab deploy``` было выполнено подключение к роутерам через ```telnet``` и их последующая настройка, в том числе:
 - Настройка DHCP-сервера для раздачи адресов
 - Настройка IP адресов на устройствах
 - Настройка статической маршрутизации

```
Скрипты всех настроек можно посмотреть в /scripts в файлах вида: R01*.bash
```

1. Настройка роутера в Москве:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/467a33e4-3063-4d4f-b5be-7024beaa3bad)

2. Настройка роутера во Франкфурте:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/401165e4-aba0-4aff-86f8-9a4a7d1a4d55)

3. Настройка роутера в Берлине:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/efb7348d-7380-4d01-ac9e-0c234c71fa43)


## Настройка компьютеров

Далее, необходимо было настроить компьютеры для соответствующих регионов, в том числе:
 - Создать DHCP
 - Настроить статическую маршрутизацию
 - Изменить имена устройств

```
Скрипты всех настроек можно посмотреть в /scripts в файлах вида: PC*.bash
```

1. Настройка PC1, находящегося в Москве:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/6ae4545d-8a29-4714-9501-f491aae49423)

2. Настройка PC2, находящегося во Франкфурте:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/60058a6a-b611-4840-87f0-3303214f7fe8)

3. Настройка PC3, находящегося в Берлине:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/b79506de-66e8-4fe9-847f-5558f9cd2dbd)

### Проверка доступности

1. Пинг с Москвы во Франкфурт и Берлин:

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/2cd57997-9266-4636-be8e-6e3cd576a4df)

2. Пинг с Франкфурта в Москву и Берлин

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/1e55e6bb-a48a-4b3c-af2d-9df4ab30acf2)

3. Пинг с Берлина в Москву и Франкфурт

![image](https://github.com/crawlic-stud/intro-to-routing-itmo-2023/assets/71011093/17ad1280-871a-4c68-ae90-acc118105398)

## Вывод

В результате работы были изучены принципы планирования IP адресов, а также настройка статической маршрутизации между ними через сетевые функции устройств.




