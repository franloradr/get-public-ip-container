#!/bin/bash

read -p "Enter a target email: " targetEmail
read -p "Enter a source gmail: " sourceGmail
read -p "Enter your source gmail app password: " appPassword
#echo "You entered $targetEmail"
#echo "You entered $sourceGmail"
#echo "You entered $appPassword"

printf "FROM ubuntu:latest \
\n \
\n#Instalamos sudo, wget, ssmtp, vim y cron. Todo con opción -y para que acepte todo que sí. \
\nRUN apt-get update && apt-get -y install sudo \
\nRUN sudo apt-get -y install wget \
\nRUN sudo apt-get -y install ssmtp \
\nRUN sudo apt-get -y install vim \
\nRUN sudo apt-get -y install cron \
\n \
\n#Configuramos el ssmtp con nuestros datos. Entre otros, hay que insertar el email y contraseña del correo gmail que va a enviar avisos \
\nRUN printf \"# \\ \
\n\\\\n# Config file for sSMTP sendmail \\ \
\n\\\\n# \\ \
\n\\\\n# The person who gets all mail for userids < 1000 \\ \
\n\\\\n# Make this empty to disable rewriting. \\ \
\n\\\\nroot=$sourceGmail \\ \
\n\\\\n# The place where the mail goes. The actual machine name is required no \\ \
\n\\\\n# MX records are consulted. Commonly mailhosts are named mail.domain.com \\ \
\n\\\\nmailhub=smtp.gmail.com:587 \\ \
\n\\\\n# Where will the mail seem to come from? \\ \
\n\\\\n#rewriteDomain= \\ \
\n\\\\n# The full hostname \\ \
\n\\\\n# hostname=c833370c3aaf \\ \
\n\\\\n# Are users allowed to set their own From: address? \\ \
\n\\\\n# YES - Allow the user to specify their own From: address \\ \
\n\\\\n# NO - Use the system generated From: address \\ \
\n\\\\nFromLineOverride=YES \\ \
\n\\\\nAuthUser=$sourceGmail \\ \
\n\\\\nAuthPass=$appPassword \\ \
\n\\\\n#UseTLS=YES \\ \
\n\\\\nUseSTARTTLS=Yes\\\\n\" > /etc/ssmtp/ssmtp.conf \
\n \
\nRUN printf \"old_ip\" > /ip.txt \
\n \
\n#Script que compara la actual ip pública con la de la iteracción anterior. Si difieren, se avisa al email de hotmail. \
\nRUN printf \"#!/bin/bash \\ \
\n\\\\ncurrent_ip=\\\$(wget -qO- https://ipecho.net/plain) \\ \
\n\\\\nold_ip=\\\$(cat ip.txt) \\ \
\n\\\\necho \\\\\"current_ip:\\\\\" \\ \
\n\\\\necho \\\$current_ip \\ \
\n\\\\necho \\\\\"old_ip:\\\\\" \\ \
\n\\\\necho \\\$old_ip \\ \
\n\\\\nif [[ \\\\\"\\\$current_ip\\\\\" != \\\\\"\\\$old_ip\\\\\" ]]; then \\ \
\n\\\\n  echo \\\\\"mismatch\\\\\" \\ \
\n\\\\n  echo \\\\\"\\\$current_ip\\\\\" > ip.txt \\ \
\n\\\\n  echo \\\\\"sending email\\\\\" \\ \
\n\\\\n  echo \\\\\"\\\$current_ip\\\\\" | /usr/sbin/ssmtp $targetEmail \\ \
\n\\\\nelse \\ \
\n\\\\n  echo \\\\\"match\\\\\" \\ \
\n\\\\n  echo \\\\\"do nothing\\\\\" \\ \
\n\\\\nfi \\ \
\n\\\\necho \\\\\"-----------------------------------------------------------\\\\\"\\\\n\" > ip.sh \
\n \
\n#RUN chmod +rxw ip.sh \
\n \
\n#Cron fails silently if you forget. \
\nRUN chmod 0744 ip.sh \
\n \
\n#Cron programado para que ejecute el script cada minuto. \
\nRUN printf \"* * * * * /ip.sh  >> /var/log/cron.log 2>&1 \\ \
\n\\\\n# An empty line is required at the end of this file for a valid cron file.\" > /etc/cron.d/ip-cron \
\n \
\n# Give execution rights on the cron job \
\nRUN chmod 0644 /etc/cron.d/ip-cron \
\n \
\n# Apply cron job \
\nRUN crontab /etc/cron.d/ip-cron \
\n \
\n# Create the log file to be able to run tail \
\nRUN touch /var/log/cron.log \
\n \
\n# Run the command on container startup \
\nCMD cron && tail -f /var/log/cron.log"> ./Dockerfile