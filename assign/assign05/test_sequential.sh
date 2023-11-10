#!/bin/bash

# Usage: ./test_concurrent.sh [port] [in_file1] [in_file2] [out stem]

#############################################
# globals section
#############################################
PORT=$1
IN1=$2
IN2=$3
OUT_STEM=$4

USER1=alice
USER2=bob
RECV_USER=eve
REF_SENDER="reference/ref-sender"
REF_RECEIVER="reference/ref-receiver"
SERVER_PID=0
ROOM="partytime"
RECEIVER_PID=0
declare -a CLIENT_PIDS

#############################################
# functions section
#############################################
cleanup() {
    local FLAGS=$1
    local PID=0
    for PID in "${CLIENT_PIDS[@]}"; do
        kill ${FLAGS} ${PID} > /dev/null 2>&1
        wait ${PID} 2> /dev/null
    done
    if [[ ${RECEIVER_PID} -ne 0 ]]; then
        kill ${FLAGS} ${RECEIVER_PID} > /dev/null 2>&1
        wait ${RECEIVER_PID} 2> /dev/null
    fi
    if [[ ${SERVER_PID} -ne 0 ]]; then
        kill ${FLAGS} ${SERVER_PID} > /dev/null 2>&1
        wait ${SERVER_PID} 2> /dev/null
    fi
    rm -rf temp
}

# cleanup all resources on error
error_cleanup () {
    echo $1
    cleanup -9
    exit 1
}

# make a pipe and hold it open using a subprocess
makepipe() {
    local NAME=$1
    mkfifo ${NAME}
    while sleep 10; do :; done > ${NAME} &
    PIPE_RES_PIDS+=($!)
}

#############################################
# Script body
#############################################
if [[ "$#" -ne 4 ]]; then
    echo "Usage: $0 [port] [in_file_1] [in_file_2] [out_stem]"
    exit 1
fi
# configure traps
trap "error_cleanup 'cleanup on ERR...'" ERR
trap "error_cleanup 'cleanup on SIGINT...'" SIGINT
trap "error_cleanup 'cleanup on SIGTERM...'" SIGTERM

# setup
rm -rf temp/
mkdir temp/

# start server
echo "spawning server"
if [[ ${VALGRIND_ENABLE} -eq 1 ]]; then
    valgrind --leak-check=full --track-origins=yes ./server ${PORT} &
    SERVER_PID=$!
else
    ./server ${PORT} &
    SERVER_PID=$!
fi

# wait for server to come up
sleep 0.5

# spawn receiver
echo "spawning receiver"
stdbuf -oL -eL \
    ${REF_RECEIVER} localhost ${PORT} ${RECV_USER} ${ROOM} \
        1> "${OUT_STEM}.out" \
        2> "${OUT_STEM}.err" &
RECEIVER_PID=$!

# wait for receiver to come up
sleep 0.5

# spawn senders
echo "Spawning first sender"
stdbuf -oL -eL ${REF_SENDER} localhost ${PORT} ${USER1} \
    < ${IN1} \
    1> /dev/null \
    2> ${USER1}.err &
echo "waiting for transmission to settle"
sleep 2

echo "Spawning second sender"
stdbuf -oL -eL ${REF_SENDER} localhost ${PORT} ${USER2} \
    < ${IN2} \
    1> /dev/null \
    2> ${USER2}.err &
echo "waiting for transmission to settle"
sleep 2

# check that server is still up
kill -0 ${SERVER_PID}
if [[ $? -ne 0 ]]; then
    echo "Server died when it was not supposed to!"
    exit 1
fi

echo "cleaning up"
cleanup
trap - ERR

exit 0
