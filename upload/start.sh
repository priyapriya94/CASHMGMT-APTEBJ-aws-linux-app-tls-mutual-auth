#!/bin/bash
env | grep APT_FI_DOMAIN_NAME >> /etc/environment
env | grep NGINX_DEBUG_MODE >> /etc/environment
env | grep HOME >> /etc/environment
env | grep AWS_CONTAINER_CREDENTIALS_RELATIVE_URI >> /etc/environment
env | grep ECS_CONTAINER_METADATA_URI >> /etc/environment
env | grep ECS_CONTAINER_METADATA_URI_v4 >> /etc/environment
env | grep CANACT_FI_DOMAIN_NAME >> /etc/environment
mkdir -p /etc/ssl/private/bmo
mkdir -p /etc/ssl/private/td
if [[ ! -z "${MUTUAL_AUTH_CA_BUNDLE_1}" ]]; then 
    echo "${MUTUAL_AUTH_CA_BUNDLE_1}" > /etc/ssl/private/mutual_auth_ca_bundle.crt
fi
if [[ ! -z "${MUTUAL_AUTH_CA_BUNDLE_2}" ]]; then 
    echo "${MUTUAL_AUTH_CA_BUNDLE_2}" >> /etc/ssl/private/mutual_auth_ca_bundle.crt
fi
echo "${BMO_CLIENT_CRT}" > /etc/ssl/private/bmo/client.crt
if [[ ! -z "${MUTUAL_AUTH_CA_BUNDLE_1}" ]]; then 
    echo "${MUTUAL_AUTH_CA_BUNDLE_1}" >> /etc/ssl/private/bmo/client.crt
fi
if [[ ! -z "${MUTUAL_AUTH_CA_BUNDLE_2}" ]]; then 
    echo "${MUTUAL_AUTH_CA_BUNDLE_2}" >> /etc/ssl/private/bmo/client.crt
fi

echo "${TD_CLIENT_CRT}" > /etc/ssl/private/td/client.crt
if [[ ! -z "${MUTUAL_AUTH_CA_BUNDLE_1}" ]]; then 
    echo "${MUTUAL_AUTH_CA_BUNDLE_1}" >> /etc/ssl/private/td/client.crt
fi
if [[ ! -z "${MUTUAL_AUTH_CA_BUNDLE_2}" ]]; then 
    echo "${MUTUAL_AUTH_CA_BUNDLE_2}" >> /etc/ssl/private/td/client.crt
fi
# echo `cat /etc/ssl/private/td/client.crt`
# echo `cat /etc/ssl/private/bmo/client.crt`
echo "${CERT_AUTH_MAP}" > /etc/nginx/sites-available/cert_auth_map.conf

/usr/sbin/crond start
FILE=/etc/ssl/private/letsencrypt-domain.pem
if [ -f "$FILE" ]; then
    echo "$FILE exists. Certificate already generated."
    ACCOUNTFILE=/etc/ssl/private/letsencrypt-account.key
    if [ -f "$ACCOUNTFILE" ]; then
    	if [[ "$CANACT_DOMAIN" == "true" ]]; then
      		acme-nginx -k $ACCOUNTFILE --dns-provider route53 -d $APT_FI_DOMAIN_NAME -d $CANACT_FI_DOMAIN_NAME --no-reload-nginx --debug
        else
      		acme-nginx -k $ACCOUNTFILE --dns-provider route53 -d $APT_FI_DOMAIN_NAME --no-reload-nginx --debug
        fi
    fi
else 
    echo "$FILE does not exist. Generating new certificate."
    ACCOUNTFILE=/etc/ssl/private/letsencrypt-account.key
    if [ -f "$ACCOUNTFILE" ]; then
    	if [[ "$CANACT_DOMAIN" == "true" ]]; then
  		    echo "Account already registered."
        	acme-nginx -k $ACCOUNTFILE --dns-provider route53 -d $APT_FI_DOMAIN_NAME -d $CANACT_FI_DOMAIN_NAME --no-reload-nginx
        else
  		    echo "Account already registered."
        	acme-nginx -k $ACCOUNTFILE --dns-provider route53 -d $APT_FI_DOMAIN_NAME --no-reload-nginx
        fi

    elif [[ "$CANACT_DOMAIN" == "true" ]]; then
      echo "Account is not registered."
      acme-nginx --dns-provider route53 -d $APT_FI_DOMAIN_NAME -d $CANACT_FI_DOMAIN_NAME --no-reload-nginx
    else
	  echo "Account is not registered."
      acme-nginx --dns-provider route53 -d $APT_FI_DOMAIN_NAME --no-reload-nginx
    fi
fi
if [[ "${NGINX_DEBUG_MODE}" == "Y" ]]; then
    nginx-debug -g "daemon off;"
else
    nginx -g "daemon off;"
fi

