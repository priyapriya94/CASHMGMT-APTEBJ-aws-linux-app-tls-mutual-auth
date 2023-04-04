datediff() {
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    echo $(( (d1 - d2) / 86400 ))
}
expDate=$(date --date="$(openssl x509 -enddate -noout -in /etc/ssl/private/letsencrypt-domain.pem |cut -d= -f 2)" --iso-8601)
currDate=$(date +%F)
currDatePlusMonth=$(date -d "$currDate+1 month" +%F)
certToExpire=$(datediff $expDate $currDatePlusMonth)
if [[ $((certToExpire)) -lt 30 ]]; then
  echo "Renew the letsencrypt cert: $APT_FI_DOMAIN_NAME"
  echo "URL: $AWS_CONTAINER_CREDENTIALS_RELATIVE_URI"
  CREDS=`curl 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`
  export AWS_ACCESS_KEY_ID=$(echo "${CREDS}" | jq -r '.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "${CREDS}" | jq -r '.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "${CREDS}" | jq -r '.Token')
  acme-nginx --dns-provider route53 -d $APT_FI_DOMAIN_NAME  -d $CANACT_FI_DOMAIN_NAME --no-reload-nginx
  if [[ "${NGINX_DEBUG_MODE}" == "Y" ]]; then
    /usr/sbin/nginx-debug -s reload
  else
    /usr/sbin/nginx -s reload
  fi
else
  certToExpire=$(($certToExpire-30))
  echo "Certificate:$APT_FI_DOMAIN_NAME is still valid for $certToExpire days"
  echo "Certificate:$CANACT_FI_DOMAIN_NAME is still valid for $certToExpire days"
fi
