#!/bin/bash
Msg=N/A
Status=unknown
systemctl is-active --quiet mongod.service
if [ $? != 0 ]; then
    Msg=Mongo_Service_NotRunning
else
    sudo netstat -tnlp | grep mongo
    if [ $? != 0 ]; then
        Msg=Mongo_Port_Not_Mapped
    else
        connect=$(mongosh admin --quiet --eval "db.version()")
        if [ $? != 0 ]; then
            Msg=Mongo_Service_Running_But_Cant_Connect
        else
            Msg=Mongo_Running_And_Reachable
        fi
    fi    
fi

aws sns publish --topic-arn <> --message $Msg --subject "Server_Status"