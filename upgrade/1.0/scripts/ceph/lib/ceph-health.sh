#!/bin/bash

function wait_for_health_ok() {
  cnt=0
  while true; do
    if [[ "$cnt" -eq 360 ]]; then
      echo "ERROR: Giving up on waiting for ceph to become healthy..."
      break
    fi
    output=$(ceph -s | grep -q HEALTH_OK)
    if [[ "$?" -eq 0 ]]; then
      echo "Ceph is healthy -- continuing..."
      break
    fi
    sleep 5
    echo "Sleeping for five seconds waiting ceph to be healthy..."
    cnt=$((cnt+1))
  done
}

function wait_for_running_daemons() {
  daemon_type=$1
  num_daemons=$2
  cnt=0
  while true; do
    if [[ "$cnt" -eq 60 ]]; then
      echo "ERROR: Giving up on waiting for $num_daemons $daemon_type daemons to be running..."
      break
    fi
    output=$(ceph orch ps --daemon-type $daemon_type -f json-pretty | jq -r '.[] | select(.status_desc=="running") | .daemon_id')
    if [[ "$?" -eq 0 ]]; then
      num_active=$(echo "$output" | wc -l)
      if [[ "$num_active" -eq $num_daemons ]]; then
        echo "Found $num_daemons running $daemon_type daemons -- continuing..."
        break
      fi
    fi
    sleep 5
    echo "Sleeping for five seconds waiting for $num_daemons running $daemon_type daemons..."
    cnt=$((cnt+1))
  done
}

function wait_for_orch_hosts() {
  for host in $(ceph node ls| jq -r '.osd|keys[]'); do
    echo "Verifying $host is in ceph orch host output..."
    cnt=0
    until ceph orch host ls -f json-pretty | jq -r '.[].hostname' | grep -q $host; do
      echo "Sleeping five seconds to wait for $host to appear in ceph orch host output..."
      sleep 5
      cnt=$((cnt+1))
      if [ "$cnt" -eq 120 ]; then
        echo "ERROR: Giving up waiting for $host to appear in ceph orch host output!"
        break
      fi
    done
  done
}

function wait_for_osd() {
  osd=$1
  cnt=0
  while true; do
    if [[ "$cnt" -eq 60 ]]; then
      echo "ERROR: Giving up on waiting for osd.$osd daemon to be running..."
      break
    fi
    output=$(ceph orch ps --daemon-type osd -f json-pretty | jq -r '.[] | select(.status_desc=="running") | .daemon_id')
    if [[ "$?" -eq 0 ]]; then
      echo "$output" | grep -q $osd
      if [[ "$?" -eq 0 ]]; then
        echo "Found osd.$osd daemon running -- continuing..."
        break
      fi
    fi
    sleep 5
    echo "Sleeping for five seconds waiting for osd.$osd running daemon..."
    cnt=$((cnt+1))
  done
}

function wait_for_osds() {
  for host in $(ceph node ls| jq -r '.osd|keys[]'); do
    for osd in $(ceph node ls| jq --arg host_key $host -r '.osd[$host_key]|values|tostring|ltrimstr("[")|rtrimstr("]")'| sed "s/,/ /g"); do
      wait_for_osd $osd
   done
 done
}
