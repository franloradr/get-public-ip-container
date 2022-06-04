# get-public-ip-container

An Ubuntu based container which includes a cron service and a bash script which is executed each minute and it does send over SSMTP Mail a notification whenever our public IP suffers a modification.

Execute the dockerfileBuilder.sh to generate the Dockerfile based on 3 variables which must be provided by the user: {targetMail}, {sourceMail} and {appPassword}.

A Dockerfile example from the script execution is added.

<p align="center">
  <img src="https://raw.githubusercontent.com/franloradr/get-public-ip-container/master/images/docker_run.png">
</p><br>