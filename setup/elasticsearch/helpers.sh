#!/bin/bash

# Verify that the given Elasticsearch user exists.
function check_user_exists {
	local es_url=$1
	local cacert=$2
	local user_name=$3

	local -a args=( '-X' 'GET' '-s' '-w' '%{http_code}'
		"${es_url}/_security/user/${user_name}"
		'--cacert' "$cacert"
		)

	local -i exists=0

	output="$(curl -X GET "${args[@]}")"
	if [[ "${output: -3}" = "200" ]]; then
		exists=1
	fi

	echo "$exists"
}

# Set password of a given Elasticsearch user.
function set_user_password {
	local es_url=$1
	local cacert=$2
	local user_name=$3
	local password=$4

	local -a args=( '-X' 'POST' '-s' '-w' '%{http_code}'
		"${es_url}/_security/user/${user_name}/_password"
		'--cacert' "$cacert"
		'-H' 'Content-Type: application/json'
		'-d' "{\"password\" : \"${password}\"}"
		)

	output="$(curl "${args[@]}")"
	if [[ "${output: -3}" != "200" ]]; then
		result=0
		echo "Setting password for user $user_name failed"
	else
	  echo "${output::-3}"
	fi
}

# Create the given Elasticsearch user and set password.
function create_user {
	local es_url=$1
	local cacert=$2
	local user_name=$3
	local password=$4
	local role=$5

	local -a args=( '-X' 'POST' '-s' '-w' '%{http_code}'
		"${es_url}/_security/user/${user_name}"
		'--cacert' "$cacert"
		'-H' 'Content-Type: application/json'
		'-d' "{\"password\":\"${password}\",\"roles\":[\"${role}\"]}"
		)

	output="$(curl "${args[@]}")"
	if [[ "${output: -3}" != "200" ]]; then
		echo "Create user $user_name failed"
	else
	  echo "${output::-3}"
	fi
}

# Ensure that the given Elasticsearch role is up-to-date, create it if required.
function ensure_role {
	local es_url=$1
	local cacert=$2
	local role=$3
	local body=$4

	local -a args=( '-X' 'POST' '-s' '-w' '%{http_code}'
		"${es_url}/_security/role/${role}"
		'--cacert' "$cacert"
		'-H' 'Content-Type: application/json'
		'-d' "$body"
		)

	output="$(curl "${args[@]}")"
	if [[ "${output: -3}" != "200" ]]; then
		echo "Create / Update role $role failed"
	else
	  echo "${output::-3}"
	fi
}