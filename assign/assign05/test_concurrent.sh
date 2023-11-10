#!/bin/bash

# Usage: ./test_concurrent.sh [port] [iterations] [settle]

#############################################
# globals section
#############################################
PORT=$1
COUNTS=$2
TIMEOUT=$3

MSG_STEM="Sending a gratuitously long message to try trigger problems in the aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa server "
ROOM="partytime"
TEMP_DIR="/tmp/${RANDOM}"
REF_SENDER="reference/ref-sender"
REF_RECEIVER="reference/ref-receiver"
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
    rm -rf ${TEMP_DIR}
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

# Main worker that sends data concurrently to the same room
send_worker() {
    local FIFO=$1
    local NAME=$2
    local IDX=0

    nc localhost ${PORT} \
        < ${FIFO} \
        > /dev/null 2>&1 &
    local PID=$!
    echo "slogin:${NAME}" > ${FIFO}
    while [[ ${IDX} -lt ${COUNTS} ]]; do
        echo "join:${ROOM}" > ${FIFO}
        echo "sendall:${MSG_STEM}${IDX}" > ${FIFO}
        echo "leave:dummy" > ${FIFO}
        IDX=$((IDX+1))
    done
    echo "quit:done" > ${FIFO}
}

# worker that joins and leaves the server in a tight loop
send_join_worker() {
    local FIFO=$1
    local NAME=$2
        mkfifo ${FIFO}

    while true; do
        nc localhost ${PORT} \
            < ${FIFO} \
            > /dev/null 2>&1 &
        (
            echo "slogin:${NAME}"
            sleep 0.05
            echo "join:${ROOM}"
            echo "leave:dummy"
            echo "join:room1"
            echo "sendall:THIS IS A A REALLLLLLLLLLLLLLLYYYYYYYYYYYY LONNNNNNNNNNNNGGGGGGGG MESSSSSSSSSAAAAAAAAAAAGGGGGGE"
            echo "join:pineapple"
            echo "sendall:THIS IS A A REALLLLLLLLLLLLLLLYYYYYYYYYYYY LONNNNNNNNNNNNGGGGGGGG MESSSSSSSSSAAAAAAAAAAAGGGGGGE"
            echo "quit:dummy"
        ) > ${FIFO}
    done
}

# worker that joins and leaves a room in a tight loop
send_stress_worker() {
    local FIFO=$1
    local NAME=$2
    nc localhost ${PORT} \
        < ${FIFO} \
        > /dev/null 2>&1 &
    echo "slogin:${NAME}" > ${FIFO}
    while true; do
        echo "join:${ROOM}" > ${FIFO}
        echo "join:bar" > ${FIFO}
        echo "join:foo" > ${FIFO}
    done
}

# receiver worker that joins and leaves a server in a tight loop
recv_join_worker() {
    local FIFO=$1
    local NAME=$2
    local PID

    while true; do
        nc localhost ${PORT} \
            < ${FIFO} \
            > /dev/null 2>&1 &
        PID=$!
        echo "rlogin:${NAME}" > ${FIFO}
        echo "join:${ROOM}" > ${FIFO}
        sleep 0.1
        kill -9 ${PID} > /dev/null 2>&1
        wait ${PID} > /dev/null 2>&1
    done
}

# function to verify a file produced by verify
verify_file() {
    local FILE=$1
    local USER=$2
    local IDX=0

    while read LINE; do
        EXPECTED="${USER}: ${MSG_STEM}${IDX}" 
        if [[ ${IDX} -ge ${COUNTS} ]]; then
            echo "too many lines in file ${FILE}"
            return 1
        fi
        if [[ "${LINE}" != "${EXPECTED}" ]]; then
            echo "expected ${EXPECTED} but got ${LINE}"
            return 1
        fi
        IDX=$((IDX+1))
    done < "${FILE}"
    if [[ ${IDX} -ne ${COUNTS} ]]; then
        echo "too few lines for file ${FILE}"
        return 1
    fi
    return 0
}

# function to verify an ouutput file
verify() {
    local FILE=$1

    # split up files by username
    grep "^bob:" ${FILE} > bob.out
    grep "^alice:" ${FILE} > alice.out
    grep "^mallory:" ${FILE} > mallory.out
    grep -Ev "^(bob|alice|mallory):" ${FILE} > other.out

    # verify non-empty files
    verify_file bob.out bob
    if [[ $? -ne 0 ]]; then
        echo "Failed to verify first sender"
        return 1;
    fi
    verify_file alice.out alice
    if [[ $? -ne 0 ]]; then
        echo "Failed to verify second sender"
        return 1;
    fi
    verify_file mallory.out mallory
    if [[ $? -ne 0 ]]; then
        echo "Failed to verify third sender"
        return 1;
    fi
    # Verify that no other output was generated
    if [[ -s other.out ]]; then
        echo "Verification error: Server sent unexpected messages"
        return 1
    fi
    if [[ -s ${FILE%.out}.err ]]; then
        echo "Verification error: Server sent unexpected errors"
        return 1
    fi
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
    echo "Usage: ./$0 [port] [iterations] [settle]"
    exit 1
fi
# configure traps
trap "error_cleanup 'cleanup on ERR...'" ERR
trap "error_cleanup 'cleanup on SIGINT...'" SIGINT
trap "error_cleanup 'cleanup on SIGTERM...'" SIGTERM

# setup
rm -rf ${TEMP_DIR}
mkdir ${TEMP_DIR}

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
    ${REF_RECEIVER} localhost ${PORT} eva ${ROOM} \
        1> "concur.out" \
        2> "concur.err" &
RECEIVER_PID=$!

# wait for receiver to come up
sleep 0.5

# spawn send workers
echo "spawning workers"
makepipe ${TEMP_DIR}/concur_1.in
send_worker ${TEMP_DIR}/concur_1.in bob &
CLIENT_PIDS+=($!)
makepipe ${TEMP_DIR}/concur_2.in
send_worker ${TEMP_DIR}/concur_2.in alice &
CLIENT_PIDS+=($!)
makepipe ${TEMP_DIR}/concur_3.in
send_worker ${TEMP_DIR}/concur_3.in mallory &
CLIENT_PIDS+=($!)
send_join_worker ${TEMP_DIR}/concur_4.in bad1 &
CLIENT_PIDS+=($!)
send_join_worker ${TEMP_DIR}/concur_5.in bad2 &
CLIENT_PIDS+=($!)
makepipe ${TEMP_DIR}/concur_6.in
recv_join_worker ${TEMP_DIR}/concur_6.in bad3 &
CLIENT_PIDS+=($!)
makepipe ${TEMP_DIR}/concur_7.in
send_stress_worker ${TEMP_DIR}/concur_7.in bad4 &
CLIENT_PIDS+=($!)
makepipe ${TEMP_DIR}/concur_8.in
send_stress_worker ${TEMP_DIR}/concur_8.in bad5 &
CLIENT_PIDS+=($!)

# wait for workers to start
sleep 0.5

# show spinner while waiting for messages to settle
spinner "running workers" &
SPINNER_PID=$!

# wait for messages to settle
sleep ${TIMEOUT}
kill ${SPINNER_PID}

# check that server is still up
kill -0 ${SERVER_PID}
echo ""
if [[ $? -ne 0 ]]; then
    echo "Server died when it was not supposed to!"
    exit 1
fi

# clean up everything
echo "cleaning up run"
cleanup
trap - ERR

echo "verifying outputs"
# verify outputs
verify concur.out

if [[ $? -eq 0 ]]; then
    echo "Tests passed successfully!"
fi

# exit with correct code
exit $?
