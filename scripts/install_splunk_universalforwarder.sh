#!/bin/bash

# ref: http://docs.splunk.com/Documentation/Splunk/6.2.2/Forwarding/Deployanixdfmanually#Install_the_universal_forwarder

if [ "$(whoami)" != "root" ]
then
	echo "You must be root to run this script"
	exit 1
fi

set -e
set -x

SPLUNK_HOST="$1"
SPLUNK_PORT="$2"

if [ -z "$SPLUNK_HOST" -o -z "$SPLUNK_PORT" ]
then
	echo "Usage: $0 <SPLUNK_HOST> <SPLUNK_PORT>"
	exit 1
fi

cd /tmp/

FILENAME="splunkforwarder-6.2.2-255606-linux-2.6-amd64.deb"
rm -f "${FILENAME}"
wget -O "${FILENAME}" "http://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=Linux&version=6.2.2&product=universalforwarder&filename=${FILENAME}&wget=true"
dpkg -i "${FILENAME}"

SPLUNK="/opt/splunkforwarder/bin/splunk"

$SPLUNK start --accept-license
$SPLUNK enable boot-start
$SPLUNK add forward-server "${SPLUNK_HOST}:${SPLUNK_PORT}" -auth admin:changeme
$SPLUNK add monitor /var/log/mhn/

echo "splunkforwarder installed and configured to monitor /var/log/mhn/"
echo "It is highly recommended that you change the password for this local splunk install"

# might want to do this...
# splunk add forward-server <host>:<port> -ssl-cert-path /path/ssl.crt -ssl-root-ca-path /path/ca.crt -ssl-password <password>
