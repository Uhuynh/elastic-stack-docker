#!/bin/bash
set -euo pipefail

echo "$(dirname ${BASH_SOURCE[0]})"
#state_file="$(dirname ${BASH_SOURCE[0]})/state/.done"
state_file=/state/.done
if [[ -e "$state_file" ]]; then
	echo "State file exists at '${state_file}', skipping initialization step"
	exit 0
fi

source "$(dirname ${BASH_SOURCE[0]})/helpers.sh"

# --------------------------------------------------------
# if CA cert does not exist then something went wrong
# with the certificate setup
cacert=/usr/share/elasticsearch/config/ca/ca.crt
if [ ! -f $cacert ]; then
    echo "CA cert does not exist. Aborting. Please check the certificate setup process."
    exit 1
fi

# --------------------------------------------------------
# if ELASTIC_PASSWORD does not exist then something went
# wrong with the env setup
if [ -z ${ELASTIC_PASSWORD} ]; then
    echo "ELASTIC_PASSWORD does not exist. Aborting. Please check the env setup process."
    exit 1
fi

# --------------------------------------------------------
# wait for Elasticsearch to start up before doing anything
echo "Waiting for Elasticsearch availability..."
es_url=https://elastic:${ELASTIC_PASSWORD}@es01:9200
while [[ "$(curl --cacert $cacert -s -o /dev/null -w '%{http_code}' $es_url)" != "200" ]]; do
    sleep 5
done
echo "Elasticsearch is running"

# --------------------------------------------------------
# Users declarations
declare -A users_passwords
users_passwords=(
	[logstash_internal]="${LOGSTASH_INTERNAL_PASSWORD:-}"
	[logstash_system]="${LOGSTASH_SYSTEM_PASSWORD:-}"
	[kibana_system]="${KIBANA_SYSTEM_PASSWORD:-}"
)

# Roles declarations
declare -A roles_files
roles_files=(
	[logstash_writer]='logstash_writer.json'
)

# users' role declarations
declare -A users_roles
users_roles=(
	[logstash_internal]='logstash_writer'
)

# --------------------------------------------------------
# Ensure that the given Elasticsearch role (defined in
# ./roles) is up-to-date, create it if required.
for role in "${!roles_files[@]}"; do
	echo "Checking role $role declaration ..."

	declare body_file
	body_file="$(dirname "${BASH_SOURCE[0]}")/roles/${roles_files[$role]:-}"
	if [[ ! -f "${body_file:-}" ]]; then
		echo "No role declaration found for $role. Skipping ..."
		continue
	fi

	echo "Creating/updating role $role ..."
	ensure_role "$es_url" "$cacert" "$role" "$(<"${body_file}")"
done

# --------------------------------------------------------
# Check / Create Elasticsearch user and set password
for user in "${!users_passwords[@]}"; do
	echo "Checking user $user"
	if [[ -z "${users_passwords[$user]}" ]]; then
		echo "No password defined for $user, skipping"
		continue
	fi

	declare -i user_exists=0
	user_exists=$(check_user_exists "$es_url" "$cacert" "$user")

	if ((user_exists)); then
		echo "User $user exists, setting password"
		set_user_password "$es_url" "$cacert" "$user" "${users_passwords[$user]}"
	else
		if [[ -z "${users_roles[$user]:-}" ]]; then
			echo "No role for $user defined, skipping creation"
			continue
		fi

		echo "User $user does not exist, creating user and set password"
		create_user "$es_url" "$cacert" "$user" "${users_passwords[$user]}" "${users_roles[$user]}"
	fi
done

# --------------------------------------------------------
# Ensure that an Azure snapshot repository exists, create
# or update it if required
repository_body_file="$(dirname "${BASH_SOURCE[0]}")/snapshot_repository/azure_repository.json"
repository_name="elk"
echo "Register a snapshot repository"
register_snapshot_repository "$es_url" "$cacert" "$repository_name" "$(<"${repository_body_file}")"

# create an SLM policy
slm_policy_body_file="$(dirname "${BASH_SOURCE[0]}")/snapshot_repository/slm_policy.json"
slm_policy_id="elk-slm-policy"
echo "Create an SLM policy"
create_slm_policy "$es_url" "$cacert" "$slm_policy_id" "$(<"${slm_policy_body_file}")"

# create an SLM retention task to automatically remove redundant snapshots
slm_retention_body_file="$(dirname "${BASH_SOURCE[0]}")/snapshot_repository/slm_retention.json"
echo "Create an SLM retention task"
create_slm_retention "$es_url" "$cacert" "$(<"${slm_retention_body_file}")"

# --------------------------------------------------------
# write to state file .done
mkdir -p "$(dirname "${state_file}")"
touch "$state_file"