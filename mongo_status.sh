#!/bin/bash
Msg=N/A
Status=unknown
systemctl is-active --quiet mongod.service
if [ $? != 0 ]; then
    Msg=Mongo_Service_NotRunning
    Status=Down
else
    sudo netstat -tnlp | grep mongo > /dev/null
    if [ $? != 0 ]; then
        Msg=Mongo_Port_Not_Mapped
        Status=Down
    else
        connect=$(mongosh admin --quiet --eval "db.version()")
        if [ "$connect" != "6.0.6" ]; then
            Msg=Mongo_Service_Running_But_Cant_Connect
            Status=Down
        else
            Msg=Mongo_Running_And_Reachable
            Status=Running
        fi
    fi    
fi