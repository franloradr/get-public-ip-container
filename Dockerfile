FROM ubuntu:latest 
 
#Instalamos sudo, wget, ssmtp, vim y cron. Todo con opción -y para que acepte todo que sí. 
RUN apt-get update && apt-get -y install sudo 
RUN sudo apt-get -y install wget 
RUN sudo apt-get -y install ssmtp 
RUN sudo apt-get -y install vim 
RUN sudo apt-get -y install cron 
 
#Configuramos el ssmtp con nuestros datos. Entre otros, hay que insertar el email y contraseña del correo gmail que va a enviar avisos 
RUN printf "# \ 
\n# Config file for sSMTP sendmail \ 
\n# \ 
\n# The person who gets all mail for userids < 1000 \ 
\n# Make this empty to disable rewriting. \ 
\nroot=source@gmail \ 
\n# The place where the mail goes. The actual machine name is required no \ 
\n# MX records are consulted. Commonly mailhosts are named mail.domain.com \ 
\nmailhub=smtp.gmail.com:587 \ 
\n# Where will the mail seem to come from? \ 
\n#rewriteDomain= \ 
\n# The full hostname \ 
\n# hostname=c833370c3aaf \ 
\n# Are users allowed to set their own From: address? \ 
\n# YES - Allow the user to specify their own From: address \ 
\n# NO - Use the system generated From: address \ 
\nFromLineOverride=YES \ 
\nAuthUser=source@gmail \ 
\nAuthPass=qwerty \ 
\n#UseTLS=YES \ 
\nUseSTARTTLS=Yes\n" > /etc/ssmtp/ssmtp.conf 
 
RUN printf "old_ip" > /ip.txt 
 
#Script que compara la actual ip pública con la de la iteracción anterior. Si difieren, se avisa al email de hotmail. 
RUN printf "#!/bin/bash \ 
\ncurrent_ip=\$(wget -qO- https://ipecho.net/plain) \ 
\nold_ip=\$(cat ip.txt) \ 
\necho \"current_ip:\" \ 
\necho \$current_ip \ 
\necho \"old_ip:\" \ 
\necho \$old_ip \ 
\nif [[ \"\$current_ip\" != \"\$old_ip\" ]]; then \ 
\n  echo \"mismatch\" \ 
\n  echo \"\$current_ip\" > ip.txt \ 
\n  echo \"sending email\" \ 
\n  echo \"\$current_ip\" | /usr/sbin/ssmtp target@mail \ 
\nelse \ 
\n  echo \"match\" \ 
\n  echo \"do nothing\" \ 
\nfi \ 
\necho \"-----------------------------------------------------------\"\n" > ip.sh 
 
#RUN chmod +rxw ip.sh 
 
#Cron fails silently if you forget. 
RUN chmod 0744 ip.sh 
 
#Cron programado para que ejecute el script cada minuto. 
RUN printf "* * * * * /ip.sh  >> /var/log/cron.log 2>&1 \ 
\n# An empty line is required at the end of this file for a valid cron file." > /etc/cron.d/ip-cron 
 
# Give execution rights on the cron job 
RUN chmod 0644 /etc/cron.d/ip-cron 
 
# Apply cron job 
RUN crontab /etc/cron.d/ip-cron 
 
# Create the log file to be able to run tail 
RUN touch /var/log/cron.log 
 
# Run the command on container startup 
CMD cron && tail -f /var/log/cron.log