#!/usr/bin/env bash

source config.sh
source functions.sh

# Input parameters.
BRANCH=$1

# Branch-specific values.
FOLDER=""
DB_NAME=""
DOCROOT_PATH=""
HOST=""
BRANCH_ALIAS=""

function generate_site_params {
    REPO_NAME=$(echo ${REPO} | awk -F .git '{ print $1 }' | awk -F / '{ print $2 }')

    BRANCH_ALIAS=$(sanitize_string ${BRANCH})

    FOLDER="${REPO_NAME}-${BRANCH_ALIAS}"

    DOCROOT_PATH="${BUILDS_ROOT}/${FOLDER}"

    DB_NAME=$(sanitize_string ${FOLDER})
    DB_NAME=${DB_NAME:0:${DB_NAME_LENGTH}}

    HOST="${FOLDER}.${DOMAIN_NAME}"
}

function setup_db {
    if ! mysql --user="${DB_USER}" --password="${DB_PASS}" -e "USE ${DB_NAME};"; then
        echo-green "Import database."
        mysql --user="${DB_USER}" --password="${DB_PASS}" --execute="CREATE DATABASE ${DB_NAME};"
        gunzip < ${DB_DUMP_PATH} | mysql -hlocalhost -u${DB_USER} -p${DB_PASS} ${DB_NAME}
    fi
}

function code_clone {
   if [ ! -d "${DOCROOT_PATH}" ]; then
        echo-green "Project does not exist. Build it from scratch."
        echo-green "git clone ${REPO} ${FOLDER}"
        cd ${BUILDS_ROOT}
        git clone ${REPO} ${FOLDER}
        cd ${FOLDER}
        git checkout ${BRANCH}
    else
        echo-green "Project exists. Updating and reinstalling."
        cd ${DOCROOT_PATH}
        git reset --hard HEAD
        git checkout -- .
        git pull
    fi
}


function configure_site {
    cd ${DOCROOT_PATH}

    # Any actions needed for site configuration.
}

function add_domain {
    cd /etc/apache2/sites-available
    CONFIG_FILE="${BRANCH_ALIAS}.conf"
    touch "${CONFIG_FILE}"
    cat > "${CONFIG_FILE}" << EOL
<VirtualHost *:80>
  ServerName ${HOST}
  ServerAlias ${BRANCH_ALIAS}.*.xip.io
  ServerAlias www.${BRANCH_ALIAS}.*.xip.io
  ServerAdmin webmaster@localhost
  DocumentRoot ${DOCROOT_PATH}
  ErrorLog \${APACHE_LOG_DIR}/error.${BRANCH_ALIAS}.log
  CustomLog \${APACHE_LOG_DIR}/access.${BRANCH_ALIAS}.log combined
  <Directory ${DOCROOT_PATH}>
     Options FollowSymlinks
     AllowOverride All
  </Directory>
</VirtualHost>
EOL
    a2ensite ${CONFIG_FILE}
    service apache2 reload
}
# Send notification to Slack.
echo-green "Build is started on the branch '${BRANCH}'"
slack_notify "${SITE_TITLE}: Build is started on the branch ${BRANCH}"

generate_site_params
setup_db
code_clone
configure_site
add_domain

CURRENT_IP=$(my_ip)
EXTERNAL_SITE_NAME="http://${BRANCH_ALIAS}.${CURRENT_IP}.xip.io"

slack_notify "${SITE_TITLE} site is ready: ${EXTERNAL_SITE_NAME}"
echo-green "Site is ready ${EXTERNAL_SITE_NAME}"
