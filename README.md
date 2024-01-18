# udm-nspawn
Umgebung für nspawn auf der UDM-Pro einrichten.

## Voraussetzungen
Unifi Dream Machine Pro mit UnifiOS Version 3.x. Erfolgreich getestet mit UnifiOS 3.2.7.

## Features
- Nach einem unifiOS Update die nspawn Umgebung wiederherstellen 
- Netzwerkumgebung für nspawn bei Reboot wiederherstellen

## Disclaimer
Änderungen die dieses Script an der Konfiguration der UDM-Pro vornimmt, werden von Ubiquiti nicht offiziell unterstützt und können zu Fehlfunktionen oder Garantieverlust führen. Alle BAÄnderungenkup werden auf eigene Gefahr durchgeführt. Daher vor der Installation: Backup, Backup, Backup!!!

## Installation
Nachdem eine Verbindung per SSH zur UDM/UDM Pro hergestellt wurde wird udm-wireguard folgendermaßen installiert:

**1. Download der Dateien**

```
mkdir -p /data/custom
dpkg -l git || apt install git
git clone https://github.com/nerdiges/udm-nspawn.git /data/custom/nspawn
chmod +x /data/custom/nspawn/udm-nspawn.sh
```

**2. Parameter im Script anpassen (optional)**

Im Script kann über einige Variable das Verhalten angepasst werden:

```
##############################################################################################
#
# Configuration
#

# Directory used to buffer offline copies of *.deb files for offline restore
dpkg_dir="$(dirname $0)/dpkg"

# Directory with brmac setup scripts
brmac_dir="$(dirname $0)/brmac"

# Storage for nspawn containers
machine_dir="/data/custom/machines"

#
# No further changes should be necessary beyond this line.
#
######################################################################################
```

Die Konfiguration kann auch in der Datei udm-nspawn.conf gespeichert werden, die bei einem Update nicht überschrieben wird.

**3. Einrichten des systemd-Service**

```
# Install udm-nspawn.service und timer definition file in /etc/systemd/system via:
ln -s /data/custom/nspawn/udm-nspawn.service /etc/systemd/system/udm-nspawn.service

# Reload systemd, enable and start the service and timer:
systemctl daemon-reload
systemctl enable udm-nspawm.service
systemctl start udm-nspawn.service
```

## Update

Das Script kann mit folgenden Befehlen aktualisiert werden:
```
cd /data/custom/nspawn
git pull origin
```
