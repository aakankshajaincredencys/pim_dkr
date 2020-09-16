#!/bin/bash

mkdir -p /run/php/

exec php-fpm7.0 -F
