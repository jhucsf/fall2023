#!/bin/bash
# Usage: ./test_client.sh <port> <client> <client_input_file> <server_input_file> <output_stem>
# script exits with client's return code
PORT=$1
CLIENT=$2
CLIENT_INPUT=$3
SERVER_INPUT=$4
OUTPUT_STEM=$5
USERNAME=alice
WAIT=5

if [[ $# -ne 5 ]]; then
    echo "Usage: ${0} [port] [sender_client] [client_in_file] [server_in_file] [output_stem]"
    exit 1
fi

# Spawn netcat "server"
# force line-by-line buffering so output can be collected even after the
# the process is killed
stdbuf -oL \
    nc -l ${PORT} \
        < ${SERVER_INPUT} \
        > ${OUTPUT_STEM}-received.out &
NETCAT_PID=$!
# automatically kill netcat if the script dies after netcat starts
trap "kill -9 ${NETCAT_PID}" ERR

# wait for server to come up before running client
sleep 1

# force line-by-line buffering so output can be collected even after the
# the process is killed
timeout ${WAIT} stdbuf -oL \
    ./${CLIENT} localhost ${PORT} ${USERNAME} \
        < ${CLIENT_INPUT} \
        1> ${OUTPUT_STEM}-client.out \
        2> ${OUTPUT_STEM}-client.err
CLIENT_PID=$!
CLIENT_RETCODE=$?

# wait for transmission
kill -9 ${NETCAT_PID}

exit ${CLIENT_RETCODE}
