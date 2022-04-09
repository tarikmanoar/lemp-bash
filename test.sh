#!/bin/bash

echo "Please enter your name: "
read php_v
if [ $php_v -eq 7 ]; then 
    php_v = 7.4
    echo "PHP Version php$php_v-"
else
    echo "PHP Version php$php_v-curl"
fi