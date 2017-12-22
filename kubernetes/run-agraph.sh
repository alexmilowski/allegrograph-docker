#!/bin/bash -e

# Make sure shared memory requirements are met.
shm_size=$(df -P /dev/shm | grep -v Filesystem | awk '{print $2}')

if [ "$shm_size" -lt 1048576 ]; then
    cat <<EOF
The container for AllegroGraph must be started with at least 1GB of
shared memory. For example, run with the following option in order
to operate correctly:
--shm-size 1g
EOF
    exit 1
fi

MODIFIED=false
if [ ! -d /data/etc ]; then
   mkdir /data/etc
   MODIFIED=true
fi
if [ ! -d /data/settings/user ]; then
   mkdir -p /data/settings/user
   MODIFIED=true
fi
if [ ! -f /data/etc/agraph.cfg ]; then
   cp /var/local/agraph/agraph.cfg /data/etc
   MODIFIED=true
fi
if [ ! -f /data/settings/user/admin ]; then
   cp /var/local/agraph/admin /data/settings/user/
   MODIFIED=true
fi
if ["$MODIFIED" = true]; then
   chown -R agraph:agraph /data
fi

function terminate {
    echo Shutting down AllegroGraph
    /app/agraph/bin/agraph-control --config /data/etc/agraph.cfg stop
    exit 0
}

trap "echo Caught signal; terminate" SIGINT SIGTERM SIGQUIT

# Start AllegroGraph daemon
/app/agraph/bin/agraph-control --config /data/etc/agraph.cfg start

# Monitor the logfile.
# This pattern (& to put the process in the background and
# then blocking using 'wait') appears to be the most reliable
# way of getting bash to respond to signals.
tail -f /data/log/agraph.log &
wait $!
