#!/bin/bash

# force initialize even without login option
source /etc/profile

if [ $# != 0 ]; then
  exec "$@"
else
  # to keep container running
  tail -f /dev/null
fi
