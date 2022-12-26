#!/bin/bash

## Static Vars
MASTODON_DNLD_URL='https://github.com/mastodon/mastodon/archive/refs/tags/v4.0.2.zip'
SCRIPTDIR=`dirname $(readlink -f $0)`

## Function
preCleanup() {
	for i in $(ls | grep mastodon);do rm -rf $i;done
}

artifact() {
	[[ $MASTODON_DNLD_URL =~ \/v([0-9|\.]+)\.zip ]] && MASTODON_VER=${BASH_REMATCH[1]}
	wget -q $MASTODON_DNLD_URL -O v$MASTODON_VER.zip && unzip -q $(echo $MASTODON_DNLD_URL | sed 's/.*tags\///')
	if [ $? -ne 0 ]; then echo 'Cannot download mastodon artifact zip'; exit 1; fi
	MASTODON_DIR=$(ls | grep mastodon)
}

setInput() {
	## PostgreSQL
	echo "Enter PostgreSQL database name for Mastodon" && read POSTGRES_DB
	echo "Enter PostgreSQL user for Mastodon" && read POSTGRES_USER
	echo "Set PostgreSQL user password" && read POSTGRES_PASSWORD
	echo "Mastodon psql database name: $POSTGRES_DB"
	echo "Mastodon psql username: $POSTGRES_USER"
	echo "Mastodon psql password: $POSTGRES_PASSWORD"
	echo "Is the above correct? Press Ctrl-C to cancel" && read DUMMY_INPUT

	## Mastodon Server
	echo "Enter Mastodon domain name" && read MASTODON_DOMAIN

	## SSL Certificate
	echo "Enter SSL Certificate absolute path" && read SSL_CERT
	if ! [ -e $SSL_CERT ]; then echo "Cert file not found!"; exit 1; fi
	echo "Enter Certificate key absolute path" && read SSL_KEY
	if ! [ -e $SSL_KEY ]; then echo "Cert key file not found!"; exit 1; fi

	echo "Mastodon domain name: $MASTODON_DOMAIN"
	echo "SSL Certificate at: $SSL_CERT"
	echo "SSL Key at: $SSL_KEY"
	echo "Is the above correct? Press Ctrl-C to cancel" && read DUMMY_INPUT
}

genSecretOtpVap() {
	echo 'Generating secrets'
	cd $MASTODON_DIR
	SECRET_KEY_BASE=$(docker-compose run --rm web bundle exec rake secret)
	OTP_SECRET=$(docker-compose run --rm web bundle exec rake secret)

	while IFS= read -r line; do
		eval $line
	done <<< $(docker-compose run --rm web bundle exec rake mastodon:webpush:generate_vapid_key)

	echo "SECRET_KEY_BASE=$SECRET_KEY_BASE"
	echo "OTP_SECRET=$OTP_SECRET"

	if [ -z $VAPID_PUBLIC_KEY ]; then echo "Error when generating VAPID KEYs"; exit 1; fi
	echo "VAPID_PUBLIC_KEY=$VAPID_PUBLIC_KEY"
	echo "VAPID_PRIVATE_KEY=$VAPID_PRIVATE_KEY"
	cd ..
}

composeFile() {
	echo 'Start setting docker-compose.yml'
	## Comment out "build ."
	sed -i 's/build/#build/g' $MASTODON_DIR/docker-compose.yml

	## Inject PostgreSQL cfg
	sed -i "/POSTGRES_HOST_AUTH_METHOD/a \ \ \ \ \ \ - 'POSTGRES_DB=${POSTGRES_DB}'" $MASTODON_DIR/docker-compose.yml
	sed -i "/POSTGRES_DB/a \ \ \ \ \ \ - 'POSTGRES_USER=${POSTGRES_USER}'" $MASTODON_DIR/docker-compose.yml
	sed -i "/POSTGRES_USER/a \ \ \ \ \ \ - 'POSTGRES_PASSWORD=${POSTGRES_PASSWORD}'" $MASTODON_DIR/docker-compose.yml

	## Replace volumes
	sed -i "/postgres14/c \ \ \ \ \ \ - postgres:/var/lib/postgresql/data" $MASTODON_DIR/docker-compose.yml
	sed -i "/redis:\/data/c \ \ \ \ \ \ - redis:/data" $MASTODON_DIR/docker-compose.yml

	## Declar volumes
	sed -i '$a\' $MASTODON_DIR/docker-compose.yml
	sed -i '$a volumes:' $MASTODON_DIR/docker-compose.yml
	sed -i '$a \ \ postgres:' $MASTODON_DIR/docker-compose.yml
	sed -i '$a \ \ redis:' $MASTODON_DIR/docker-compose.yml
}

envFile() {
	echo 'Start setting .env.production'
	sed -i -E "s/LOCAL_DOMAIN=.*/LOCAL_DOMAIN=${MASTODON_DOMAIN}/g" $MASTODON_DIR/.env.production
	sed -i -E "s/REDIS_HOST=.*/REDIS_HOST=${MASTODON_DIR}_redis_1/g" $MASTODON_DIR/.env.production
	sed -i -E "s/DB_HOST=.*/DB_HOST=${MASTODON_DIR}_db_1/g" $MASTODON_DIR/.env.production
	sed -i -E "s/DB_USER=.*/DB_USER=${POSTGRES_USER}/g" $MASTODON_DIR/.env.production
	sed -i -E "s/DB_NAME=.*/DB_NAME=${POSTGRES_DB}/g" $MASTODON_DIR/.env.production
	sed -i -E "s/DB_PASS=/&${POSTGRES_PASSWORD}/g" $MASTODON_DIR/.env.production
	sed -i -E "s/SECRET_KEY_BASE=/&${SECRET_KEY_BASE}/g" $MASTODON_DIR/.env.production
	sed -i -E "s/OTP_SECRET=/&${OTP_SECRET}/g" $MASTODON_DIR/.env.production
	sed -i -E "s/VAPID_PRIVATE_KEY=/&${VAPID_PRIVATE_KEY}/g" $MASTODON_DIR/.env.production
	sed -i -E "s/VAPID_PUBLIC_KEY=/&${VAPID_PUBLIC_KEY}/g" $MASTODON_DIR/.env.production
}

## Start execution
preCleanup

setInput
artifact
composeFile

cp $MASTODON_DIR/.env.production.sample $MASTODON_DIR/.env.production

genSecretOtpVap
envFile

cd $MASTODON_DIR
docker-compose up -d
