#!/bin/sh

ssh -i /root/.ssh/open-vm-tools \
  -o StrictHostKeyChecking=no \
  root@localhost "shutdown $@"
