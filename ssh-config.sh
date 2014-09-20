##
## usage: ssh-config.sh <HostName> <IdentityFile>
##
if [ -z "$2" ]; then
	echo "illegal args"
	exit 1
fi

HOST_NAME=$1
IDENTITY_FILE=$2

cat<<EOF
Host default
  HostName $HOST_NAME
  User ubuntu
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile $IDENTITY_FILE
  IdentitiesOnly yes
  LogLevel FATAL
EOF
