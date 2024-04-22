#!/bin/bash

total_threads=$(lscpu | awk '/Thread\(s\) per core/{threads_per_core=$NF} /Core\(s\) per socket/{cores_per_socket=$NF} /Socket\(s\)/{sockets=$NF} END{print threads_per_core * cores_per_socket * sockets}')


threads_to_use=$(( $total_threads - 1 ))

echo "X, Z, BZ_VALUE" > value_on_plane.csv
for batch in $(seq 0 $(($threads_to_use-1))); do
	./currentcoil $batch $threads_to_use >> value_on_plane.csv &
done

wait
