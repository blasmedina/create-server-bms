#!/usr/bin/env bash

get_public_ip() {
    local PUBLIC_IP=$(dig @resolver1.opendns.com ANY myip.opendns.com +short)
    echo "$PUBLIC_IP"
}

main() {
    local DOMAIN="blasmedina.cl"
    create_zone
}

create_zone() {
    local DATE=$(date '+%Y%m%d')
    local IP=$(get_public_ip)
    local SERIAL="${DATE}00"
    local HOUR=$((60 * 60))
    local DAY=$(($HOUR * 24))
    local WEEK=$(($DAY * 7))
    local HASH_01=$(head -n 1 $PWD/_acme-challenge-01.txt)
    local HASH_02=$(head -n 1 $PWD/_acme-challenge-02.txt)
    local CONTENT=$(cat <<-EOF
\$ttl $HOUR
${DOMAIN}.  IN      SOA     $HOSTNAME. root.${DOMAIN}. (
                        ${SERIAL} ; serial
                        $(($HOUR * 3)) ; time to refresh
                        $HOUR ; time to retry
                        $WEEK ; time to expire
                        $DAY ; minimum TTL
            )
@                                   IN      NS      ${DOMAIN}.
${DOMAIN}.                      IN      A       ${IP}
ns1.${DOMAIN}.                  IN      A       ${IP}
www                                 IN      CNAME   ${DOMAIN}.
_acme-challenge.${DOMAIN}.  1   IN      TXT     "${HASH_01}"
_acme-challenge.${DOMAIN}.  1   IN      TXT     "${HASH_02}"
EOF
)
    echo "$CONTENT"
}

main "$@"
