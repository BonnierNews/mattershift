#!/bin/bash -e

DB_HOST=${DATABASE_SERVICE_NAME:-db}
MM_USERNAME=${MM_USERNAME:-mmuser}
MM_PASSWORD=${MM_PASSWORD:-mmuser_password}
MM_DBNAME=${MM_DBNAME:-mattermost}
MM_CONFIG=/opt/mattermost/storage/config/config.json
MM_AT_REST_ENCRYPT_KEY=${MM_AT_REST_ENCRYPT_KEY:-530439d74c49dcacc07eb6c6be85eec6a0a0c0fd}
MM_PUBLIC_LINK_SALT=${MM_PUBLIC_LINK_SALT:-802576a225a29030d58074d6ef377d4fbbb64b5f}
MM_RESET_SALT=${MM_RESET_SALT:-4d50e662a9b82d54c9a4e37411e7675b07c59b5c}
MM_INVITE_SALT=${MM_INVITE_SALT:-fda755b1c1faac19dea05b5d3d4dbefafed81754}
echo "Entrypoint"
if [ "${1:0:1}" = '-' ]; then
    set -- platform "$@"
fi
if [ "$1" = './platform' ]; then
    for ARG in $@;
    do
        case "$ARG" in
            -config=*)
                MM_CONFIG=${ARG#*=};;
        esac
    done

    echo "Using config file" $MM_CONFIG
    echo "Setting up storage..."
    mkdir -p /opt/mattermost/storage/data /opt/mattermost/storage/config
    echo -ne "Configure Mattermost..."
    if [ ! -f $MM_CONFIG ]
    then
        cp /tmp/config.json ${MM_CONFIG}
        sed -Ei "s/DB_HOST/$DB_HOST/" $MM_CONFIG
        sed -Ei "s/MM_USERNAME/$MM_USERNAME/" $MM_CONFIG
        sed -Ei "s/MM_PASSWORD/$MM_PASSWORD/" $MM_CONFIG
        sed -Ei "s/MM_DBNAME/$MM_DBNAME/" $MM_CONFIG
        sed -Ei "s/MM_AT_REST_ENCRYPT_KEY/$MM_AT_REST_ENCRYPT_KEY/" $MM_CONFIG
        sed -Ei "s/MM_PUBLIC_LINK_SALT/$MM_PUBLIC_LINK_SALT/" $MM_CONFIG
        sed -Ei "s/MM_RESET_SALT/$MM_RESET_SALT/" $MM_CONFIG
        sed -Ei "s/MM_INVITE_SALT/$MM_INVITE_SALT/" $MM_CONFIG
        echo OK
    else
        echo SKIP
    fi
    rm -f /opt/mattermost/config/config.json
    ln -s /opt/mattermost/storage/config/config.json /opt/mattermost/config/config.json

    echo "Starting Mattermost platform"
fi

exec "$@"
