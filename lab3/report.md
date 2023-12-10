- University: [ITMO University](https://itmo.ru/ru/)
- Faculty: [FICT](https://fict.itmo.ru)
- Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)
- Year: 2023/2024
- Group: K33212
- Author: Kuznetsov Nikita Sergeevich
- Lab: Lab2
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
