#!/bin/sh

set -e -x

# initialization
# test -f ~/.ssh/id_rsa.pub
rm -f ~/.ssh/known_hosts

# set opnstack params
export OS_TENANT_NAME=demo
export OS_USERNAME=admin
export OS_PASSWORD=nova
export OS_AUTH_URL="http://localhost:5000/v2.0/"
IMG=`nova --no_cache image-list | grep 'uec ' | cut -f2 -d\ `

# create tenants/users/networks
keystone tenant-create --name even --enabled true
keystone tenant-create --name odd  --enabled true
EVENID=`keystone tenant-list | grep even | cut -d' ' -f2`
ODDID=`keystone tenant-list  | grep odd  | cut -d' ' -f2`
keystone user-create --name evenuser --tenant_id $EVENID --pass evenpass --enabled true
keystone user-create --name odduser  --tenant_id $ODDID  --pass oddpass  --enabled true
nova-manage network create --label=evennet --fixed_range_v4=10.4.4.0/24 
nova-manage network create --label=oddnet  --fixed_range_v4=10.5.5.0/24 

# create even vms
export OS_TENANT_NAME=even
export OS_USERNAME=evenuser
export OS_PASSWORD=evenpass
EVENNET=`nova-manage network list 2>/dev/null | grep 10.4.4.0/24 | cut -f9`
nova --no_cache keypair-add --pub_key ~/.ssh/id_rsa.pub keyeven
nova --no_cache boot --key_name keyeven --image $IMG --flavor 1 --nic net-id=$EVENNET even01
nova --no_cache boot --key_name keyeven --image $IMG --flavor 1 --nic net-id=$EVENNET even02

# create odd vms
export OS_TENANT_NAME=odd
export OS_USERNAME=odduser
export OS_PASSWORD=oddpass
ODDNET=`nova-manage network list 2>/dev/null | grep 10.5.5.0/24 | cut -f9`
nova --no_cache keypair-add --pub_key ~/.ssh/id_rsa.pub keyodd
nova --no_cache boot --key_name keyodd --image $IMG --flavor 1 --nic net-id=$ODDNET  odd01
nova --no_cache boot --key_name keyodd --image $IMG --flavor 1 --nic net-id=$ODDNET  odd02
