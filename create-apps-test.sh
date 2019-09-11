#!/bin/bash

for i in {0..9}
do
    APP_TEST_NAME="app-00${i}"
    APP_TEST_POST="300${i}"
    source create-app-test.sh
done
