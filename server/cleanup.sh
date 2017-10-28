#!/usr/bin/env bash

# Removes all obsolete builds (when origin branch was removed).
# Should run regularly on cron.

source config.sh
source functions.sh

# Branch-specific values.
DB_NAME=""
BRANCH_ALIAS=""

function generate_site_params {
    REPO_NAME=$(echo ${REPO} | awk -F .git '{ print $1 }' | awk -F / '{ print $2 }')

    BRANCH_ALIAS=$(sanitize_string ${ACTIVE_BRANCH})

    FOLDER_NAME="${REPO_NAME}-${BRANCH_ALIAS}"

    DOCROOT_PATH="${BUILDS_ROOT}/${FOLDER_NAME}"

    DB_NAME=$(sanitize_string ${FOLDER_NAME})
    DB_NAME=${DB_NAME:0:${DB_NAME_LENGTH}}
}

echo-green "Analyzing..."

cd ${BUILDS_ROOT}
# Get all build folders.
FOLDERS=$(find * -maxdepth 0 -type d)
for FOLDER in ${FOLDERS}
do
    cd ${FOLDER}
    git fetch origin
    git remote prune origin

    # Get current branch and list of all remote branches.
    ACTIVE_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    BRANCHES=$(git branch --all | cut -c 2-)
    for BRANCH in ${BRANCHES}
    do
        generate_site_params

        # Check if active branch has remote.
        IFS='/' read -a PARTS <<< "${BRANCH}"
        REMOTES=${PARTS[0]}

        if [[ "${BRANCH}" == *"${ACTIVE_BRANCH}" ]] && [ "${REMOTES}" == "remotes" ]; then
            DELETE=0
            break
        else
            DELETE=1
        fi
    done

    if [ ${DELETE} == 1 ];
    then
        echo-red "${FOLDER} --- can be deleted."

        # Drop site-related database.
        mysql --user="${DB_USER}" --password="${DB_PASS}" --execute="DROP DATABASE ${DB_NAME};"

        # Remove Virtual Host configuration.
        CONFIG_FILE="${BRANCH_ALIAS}.conf"
        a2dissite ${CONFIG_FILE}
        rm "/etc/apache2/sites-available/${CONFIG_FILE}"
        service apache2 reload

        cd ..
        rm -rf ${FOLDER}

        CURRENT_IP=$(my_ip)
        EXTERNAL_SITE_NAME="http://${BRANCH_ALIAS}.${CURRENT_IP}.xip.io"

        slack_notify "${SITE_TITLE} site ${EXTERNAL_SITE_NAME} has been removed."
    else
        echo-red "${FOLDER} --- can NOT be deleted."
        cd ../
    fi
done

echo-green "Cleanup is finished."
