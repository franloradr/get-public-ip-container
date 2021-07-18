# get-public-ip-container

Ubuntu based container with cron and a bash script which is executed each minute and send through ssmtp mail a notification in case of public ip change.

Execute dockerfileBuilder.sh to generate the Dockerfile based on targetMail, sourceMail and appPassword inserted.

A Dockerfile example from script execution is added.