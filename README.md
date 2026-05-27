# debian-cli-secure-network
# Architecture Réseau Entreprise Segmentée

## Présentation du projet
J'ai conçu et déployé une infrastructure réseau d'entreprise complète.

L'intégralité de ce projet a été réalisée en **ligne de commande (CLI)** sur des distributions Debian pures, simulant l'environnement réel de serveurs de production.

## Architecture & plan d'adressage réseau
L'infrastructure est segmentée en trois zones distinctes via l'hyperviseur VirtualBox :

* **VM 1 : Routeur & pare-feu**
    * `enp0s3` : IP Dynamique (Interface NAT pour l'accès Internet)
    * `enp0s8` : `192.168.10.1/24` (Passerelle de la zone DMZ)
    * `enp0s9` : `192.168.20.1/24` (Passerelle de la zone LAN interne)
* **VM 2 : Serveur Web public (Debian CLI en zone DMZ)**
    * `enp0s3` : `192.168.10.10/24` (Passerelle : `192.168.10.1`)
* **VM 3 : Serveur interne (Debian CLI en zone LAN sécurisée)**
    * `enp0s3` : `192.168.20.10/24` (Passerelle : `192.168.20.1`)

---

## Réalisations techniques

### 1. Routage linux CLI
- Activation de l'IP Forwarding au niveau du noyau Linux (`sysctl`).
- Configuration manuelle et persistante des interfaces réseaux via `/etc/network/interfaces`.

### 2. Sécurisation périmétrique
Mise en place d'un filtrage réseau strict basé sur `iptables` sur la VM 1 avec une politique par défaut à `DROP` pour le transit (`FORWARD`).
- **Stateful inspection :** Suivi des connexions via le module `conntrack` (`RELATED,ESTABLISHED`).
- **Cloisonnement DMZ/LAN :** Interdiction absolue pour la DMZ d'initier une connexion vers le LAN Interne afin de bloquer toute tentative de pivot en cas de compromission du serveur Web.
- **Masquerading (NAT) :** Autorisation des flux sortants vers Internet pour les mises à jour des serveurs via la table NAT.

---

## Preuves de concept & validation (tests de connectivité)

Pour valider l'étanchéité de mon architecture réseau, les tests suivants ont été menés avec succès :

1. **Ping depuis le LAN (VM 3) vers la DMZ (VM 2) :** `SUCCESS` (L'administration et la communication vers la DMZ sont permises).
2. **Ping depuis la DMZ (VM 2) vers le LAN (VM 3) :** `FAILED (Packet Filtered)` -> *Preuve que le pare-feu bloque le flux et isole le LAN conformément à la politique de sécurité.*

---

