#!/bin/bash

# Este é o script  que criará os arquivos de log do Apache

systemctl status httpd | grep -i active > /efs/robert/status.txt
DATE=$(date +"%d-%m-%Y--%T")

if cat /efs/robert/status.txt | grep -q "running"; then
        touch $DATE--Apache--RUNNING
        echo "O Apache está rodando!" > $DATE--Apache--RUNNING
        mv $DATE--Apache--RUNNING /efs/robert/logs/
        exit 0

elif cat /efs/robert/status.txt | grep -q "dead"; then
        touch $DATE--Apache--DEAD
        echo "O Apache não está rodando!" > $DATE--Apache--DEAD
        mv $DATE--Apache--DEAD /efs/robert/logs/
        exit 0
fi

