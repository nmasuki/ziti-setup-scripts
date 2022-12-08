#!/bin/sh
if [ "$ZITI_CLIENT" == "" ]; then
    client_name=$1
    if ["$1" == ""]; then
        echo "Enter client id (Alphanumeric only):"
        read client_name
    fi

    export ZITI_CLIENT=$client_name
fi

# Load env variable 
source ~/.ziti/quickstart/${ZITI_CLIENT}/${ZITI_CLIENT}.env

#Call zitiLogin first before using ziti command
zitiLogin

# Create Demo Setup client identity
ziti edge create identity user windowsweb -o windowsweb.jwt
ziti edge create identity device ubuvm -o ubuvm.jwt

# Create the host/intercept configs
ziti edge create config sample-web-app-host.v1 host.v1 '{"protocol":"tcp", "address":"sample-web-app","port":8000}'
ziti edge create config sample-web-app-intercept.v1 intercept.v1 '{"protocols":["tcp"],"addresses":["sample-web-app.ziti"], "portRanges":[{"low":8000, "high":8000}]}'

# Create the service
ziti edge create service sample-web-app --configs "sample-web-app-intercept.v1", "sample-web-app-host.v1"

# Create the service policies
ziti edge create service-policy sample-web-app-binding Bind --service-roles '@sample-web-app' --identity-roles '@ubuvm'
ziti edge create service-policy sample-web-app-dialing Dial --service-roles '@sample-web-app' --identity-roles '@windowsweb'
ziti edge create service-policy sample-web-app-dialing Dial --service-roles '@sample-web-app' --identity-roles '@android'