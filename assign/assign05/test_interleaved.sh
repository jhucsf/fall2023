#!/bin/bash

# Usage: ./test_interleaved.sh [port] [infile] [out_stem]

#############################################
# globals section
#############################################
PORT=$1
INFILE=$2
OUT_STEM=$3

REF_SENDER="reference/ref-sender"
REF_RECEIVER="reference/ref-receiver"

USER1=alice
USER2=bob
RECV_USER=Eve
ROOM="partytime"
SETTLE=0.5

SENDER1_FIFO="temp/1.in"
SENDER2_FIFO="temp/2.in"
ALL_SEND_INPUTS=(${SENDER1_FIFO} ${SENDER2_FIFO})

SERVER_PID=0
RECEIVER_PID=0
declare -a CLIENT_PIDS
declare -a PIPE_RES_PIDS
#############################################
# functions section
#############################################
cleanup() {
    local FLAGS=$1
    local PID=0
    for PID in "${PIPE_RES_PIDS[@]}"; do
        kill ${FLAGS} ${PID} > /dev/null 2>&1
        wait ${PID} 2> /dev/null
    done
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

# spinner to make stuff look pretty in the terminal
spinner() {
    local TEXT=$1
    local TIME=0.1

    while true; do
        echo -ne "${TEXT} ⠋\x1b[0G"
        sleep ${TIME}
        echo -ne "${TEXT} ⠙\x1b[0G"
        sleep ${TIME}
        echo -ne "${TEXT} ⠹\x1b[0G"
        sleep ${TIME}
        echo -ne "${TEXT} ⠸\x1b[0G"
        sleep ${TIME}
        echo -ne "${TEXT} ⠼\x1b[0G"
        sleep ${TIME}
        echo -ne "${TEXT} ⠴\x1b[0G"
        sleep ${TIME}
        echo -ne "${TEXT} ⠦\x1b[0G"
        sleep ${TIME}
        echo -ne "${TEXT} ⠧\x1b[0G"
        sleep ${TIME}
        echo -ne "${TEXT} ⠇\x1b[0G"
        sleep ${TIME}
        echo -ne "${TEXT} ⠏\x1b[0G"
        sleep ${TIME}
    done
}

#############################################
# Script body
#############################################
if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 [port] [infile] [out_stem]"
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

# spawn send workers
echo "spawning first sender"
makepipe ${SENDER1_FIFO}
stdbuf -oL -eL ${REF_SENDER} localhost ${PORT} ${USER1} \
    < ${SENDER1_FIFO} \
    1> /dev/null \
    2> ${USER1}.err &

echo "spawning second sender"
makepipe ${SENDER2_FIFO}
stdbuf -oL -eL ${REF_SENDER} localhost ${PORT} ${USER2} \
    < ${SENDER2_FIFO} \
    1> /dev/null \
    2> ${USER2}.err &

# wait for workers to start
sleep 0.5

spinner "Sending inputs" &
SPINNER_PID=$!

INDEX=0
while read LINE; do
    echo "${LINE}" > "${ALL_SEND_INPUTS[$INDEX]}"
    INDEX=$((INDEX+1))
    if [[ $INDEX -eq ${#ALL_SEND_INPUTS[@]} ]]; then
        INDEX=0
    fi
    sleep ${SETTLE}
done < "${INFILE}"

kill ${SPINNER_PID}
echo ""

# check that server is still up
kill -0 ${SERVER_PID}
if [[ $? -ne 0 ]]; then
    echo "Server died when it was not supposed to!"
    exit 1
fi

# clean up everything
echo "cleaning up"
cleanup
trap - ERR

exit 0
