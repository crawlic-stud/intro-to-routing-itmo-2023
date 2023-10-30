# Отчет по лабораторной работе №1 "Установка ContainerLab и развертывание тестовой сети связи"

## Цель работы

Научиться пользоваться ```containerlab```, реализовать базовую сеть из роутера, трех коммутаторов и двух ПК, а также провести их конфигурацию и проверить работоспособность.

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



