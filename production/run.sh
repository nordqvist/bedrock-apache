#!/bin/bash

echo "Cleaning up!"
apt-get clean
rm -r /var/lib/apt/lists/*
rm /usr/local/bin/wp
rm /usr/local/bin/composer
echo "Starting Apache!"
apache2-foreground