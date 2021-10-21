#!/bin/bash
for i in $(seq 10 100); do
	timeout 1 bash -c "ping 10.0.0.$i -c 1" >/dev/null 2>&1 && echo "10.0.0.$i" &
done
