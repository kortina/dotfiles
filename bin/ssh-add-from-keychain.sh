#!/usr/bin/env bash
# script to ssh-add primary ssh key using passphrase stored in mac keychain
ssh-add -l | grep '.ssh/id_rsa ' > /dev/null || ssh-add --apple-use-keychain
