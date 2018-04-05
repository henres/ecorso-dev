#!/usr/bin/env bash

function usage() {
	echo "Usage: install.sh [OPTIONS]"
	echo "  [OPTIONS]:"
	echo "    [--nginx-use-https]: use https as protocole (default: http)"
	echo "    [--nginx-host <value>]: Set a HOST for nginx. (default: local.espace-perso)"
	echo "    [--nginx-port <value>]: Set a PORT mapping for nginx. (default: 38080)"
	echo "    [--stop-docker <value>]: Stop docker-compose. (default: false)"
	echo "    [--init-symfony <value>]: Stop docker-compose. (default: false)"
	exit 1
}

function cloneIfNeeded() {
	if [ ! -d "${PROJECT_PATH}" ]; then
		echo -e "\033[0;31mProject not cloned yet. Cloning...\033[0m";
		git clone git@gitlab.henres.com:ecorso/ecorso.git "${PROJECT_PATH}";
	else
		local __project_pwd=$(cd "${PROJECT_PATH}" && pwd)
		echo -e "\033[0;32mProject already exists in [${__project_pwd}]. No need to clone.\033[0m";
	fi
}

function createEnvFileIFNotExist() {
	if [ ! -f ".env" ]; then
		echo -e "\033[0;32mEnv file doesn't existing yet. Creating...\033[0m";
		cp sample.env .env
	fi
}

function checkUserId() {
	echo -e "\033[0;32mAdd Current user id to env for building docker container.\033[0m";
	sed -i.bak '/USER_ID/d' .env
	echo "USER_ID=${CURRENT_USER_ID}" >> .env
}

function initArgsAndOptions() {
	while test $# -gt 0; do
		case "$1" in
			-h|--help)
				usage
				exit 1
				;;
			--reset)
				RESET=true
				shift
				;;
			--)
				;;
			-?*)
				printf '\e[4;33mWARN: Unknown option (ignored): %s\n\e[0m' "$1" >&2
				;;
			*)
				NB_ARG=$((${NB_ARG} + 1))
				ARGS+=("$1")
				;;
		esac
		shift
	done
}

main() {
	local CURRENT_DIR=$( cd "$( dirname $0 )" && pwd )
	local PROJECT_PATH="${CURRENT_DIR}/../ecorso"
	local CURRENT_USER=$(whoami | sed 's#.*\\\(.*\)#\1#')
	local CURRENT_USER_ID=$(id -u)
	local NGINX_PORT="38080"
	local NGINX_HOST="ecorso.dev"
	local NGINX_PROTOCOL_HTTPS=false

	local NO_RECREATE=false
	local FORCE_RECREATE=false
	local CLEAN_AND_RECREATE=false

	local NB_ARG=0
	local DEBUG=false
	local ARGS=()

	initArgsAndOptions $*

	if [ true = "${DEBUG}" ]; then
		set -x
	fi

	if [ "${NB_ARG}" -gt 3 ]; then
		usage
	fi
	createEnvFileIFNotExist
	checkUserId
	cloneIfNeeded
	(
	docker-compose build --pull
	docker-compose pull
	docker-compose up -d
	)
}

main $*
