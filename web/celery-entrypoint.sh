#!/bin/bash

if [ "$DATABASE" = "postgres" ]; then
	echo "Waiting for postgres..."

	while ! nc -z db 5432; do
		sleep 0.1
	done

	echo "PostgreSQL started"
fi

python3.8 manage.py makemigrations --noinput
python3.8 manage.py migrate --noinput
python3.8 manage.py collectstatic --no-input --clear

python3.8 manage.py loaddata fixtures/default_scan_engines.yaml --app scanEngine.EngineType
#Load Default keywords
python3.8 manage.py loaddata fixtures/default_keywords.yaml --app scanEngine.InterestingLookupModel

# install firefox https://askubuntu.com/a/1404401 \
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap1-0ubuntu2
Pin-Priority: -1
' | tee /etc/apt/preferences.d/mozilla-firefox
apt update
apt install firefox -y --allow-downgrades

# update whatportis
yes | whatportis --update

# check if default wordlist for amass exists
if [ ! -f /usr/src/wordlist/deepmagic.com-prefixes-top50000.txt ]; then
	wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -O /usr/src/wordlist/deepmagic.com-prefixes-top50000.txt
fi

# test tools, required for configuration
naabu && subfinder && amass && nuclei
cp static/img/none.png ../scan_results/none.png
exec "$@"
