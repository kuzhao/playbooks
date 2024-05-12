# This bash script does following:
# 1. Collect all child pids of the given pid through the first arg, save them into envvar "PIDS"
# 2. For each of the pids, add it to '-p' arg of strace and then execute the strace command
# Each of the above items should be written into a function

# Function to collect all child pids of the given pid
function collect_child_pids() {
    local pid=$1
    local pids=$(pgrep -P $pid)
    for child_pid in $pids; do
        PIDS="$PIDS $child_pid"
        collect_child_pids $child_pid
    done
}

# Function to trace the given pid
function trace_pid() {
    # First, loop through all items in env var "PIDS", and append each with prefix '-p' to a variable
    local pids=""
    for p in $PIDS; do
        pids="$pids -p $p"
    done
    # Then, construct the strace command string and evaluate it
    local cmd="strace $pids"
    echo "
    $cmd
    "
    eval $cmd
}

# Main function
function main() {
    local pid=$1
    PIDS="$pid"
    collect_child_pids $pid
    for pid in $PIDS; do
        trace_pid $pid
    done
}

main