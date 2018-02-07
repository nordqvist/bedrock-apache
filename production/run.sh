#!/bin/bash

echo "Cleaning up!"
apt-get clean
rm -r /var/lib/apt/lists/*
echo "Starting Apache!"
apache2-foreground