#!/usr/bin/env bash
echo 'TestingTesting'
docker build . -t 10.1.0.7:3333/spring-mysql:1.0; docker images | grep spring-mysql

#If docker build fails then exit!
if [[ $? -eq 0 ]]
then
	echo -e "\e[35m docker build success \e[00m"
else
	echo -e "\e[33m docker build failed \e[00m"
	exit 1
fi


echo 'Pushing'
docker push 10.1.0.7:3333/spring-mysql:1.0; echo $?; echo test

echo "Deployment of spring-mysql"
if [[ -e spring-mysql-dp.yaml ]]
then
	scp -i $HOME/id_rsa -P 9999 spring-mysql-dp.yaml vagrant@172.17.0.1:/home/vagrant/
        ssh -i $HOME/id_rsa -p 9999 vagrant@172.17.0.1 '/usr/bin/kubectl get deploy spring-mysql'
	if [[ $? -eq 0 ]]
	then
		echo "spring-mysql deploy already exists , apply!"
                ssh -i $HOME/id_rsa -p 9999 vagrant@172.17.0.1 '/usr/bin/kubectl apply -f spring-mysql-dp.yaml'
        else
		echo "spring-mysql deploy not exists , create!"
	ssh -i $HOME/id_rsa -p 9999 vagrant@172.17.0.1 '/usr/bin/kubectl create -f spring-mysql-dp.yaml'
        fi
else
	echo "spring-mysql-dp.yaml not exists"
	exit 1
fi

echo "Deployment of spring-mysql-svc"
if [[ -e spring-mysql-svc.yaml ]]
then
	scp -i $HOME/id_rsa -P 9999 spring-mysql-svc.yaml vagrant@172.17.0.1:/home/vagrant/
        ssh -i $HOME/id_rsa -p 9999 vagrant@172.17.0.1 '/usr/bin/kubectl get svc spring-mysql'
	if [[ $? -eq 0 ]]
	then
		echo "spring-mysql svc already exists , apply!"
                ssh -i $HOME/id_rsa -p 9999 vagrant@172.17.0.1 '/usr/bin/kubectl apply -f spring-mysql-svc.yaml'
	else

		echo "spring-mysql svc not exists , apply!"
	        ssh -i $HOME/id_rsa -p 9999 vagrant@172.17.0.1 '/usr/bin/kubectl create -f spring-mysql-svc.yaml'
	fi
else
	echo "spring-mysql-svc.yaml not exists"
	exit 1
fi

CHK(){
	if [[ $? -eq 0 ]]
        then
		 echo "Deployment of spring-mysql Success!"
    	         exit 0
        fi
 }

#Default duration check time until service on.
NOWTIME=$(date +%s)
#5 MINUTES
TILTIME=300
TILTIMECOMPLETE=$(($NOWTIME+$TILTIME))
while true
do
 ssh -i $HOME/id_rsa -p 9999 vagrant@172.17.0.1 'curl http://10.1.0.3:32339/demo/all'
 CHK
 ssh -i $HOME/id_rsa -p 9999 vagrant@172.17.0.1 'curl http://10.1.0.4:32339/demo/all'
 CHK
 ssh -i $HOME/id_rsa -p 9999 vagrant@172.17.0.1 'curl http://10.1.0.4:32339/demo/all'
 CHK
 CURRENTIME=$(date +%s)
 DURATION_SEC=$(($CURRENTIME-$NOWTIME))
 echo "DURATION_SEC=$DURATION_SEC"
 echo 
 #If current time unix epoch time is more than 5 minutes..since check service..then..stop..exit
 if [[ $CURRENTIME -ge $TILTIMECOMPLETE ]]
 then
	 echo "Service wait time ends"
	 exit 0
 fi
done
