#!/bin/bash
# Vidage des règles existantes
iptables -F
iptables -t nat -F

# On bloque tout le transit
iptables -P FORWARD DROP

# Autoriser le suivi de connexion 
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Autoriser le LAN à parler à la DMZ
iptables -A FORWARD -i enp0s9 -o enp0s8 -j ACCEPT

# Autoriser le LAN et la DMZ à sortir sur Internet
iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
iptables -A FORWARD -i enp0s9 -o enp0s3 -j ACCEPT

# Activation du NAT pour l'accès Internet
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
