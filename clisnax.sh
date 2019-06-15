#!/bin/bash
# Change path accordingly:
CLISNAX=/root/producer/clisnax
$CLISNAX -u https://cdn.snax.one --wallet-url http://127.0.0.1:8900 "$@"
