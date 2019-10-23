#!/usr/bin/env bash

get_public_ip() {
    local PUBLIC_IP=$(dig @resolver1.opendns.com ANY myip.opendns.com +short)
    echo "$PUBLIC_IP"
}

main() {
    local IP=$(get_public_ip)
    echo "$IP"
}

main "$@"
