#!/usr/bin/env bash
while true; do
echo "Enter first number"
read x
if [[ $x =~ ^[0-9]+$ ]]; then
    echo $x
    break;
fi
done