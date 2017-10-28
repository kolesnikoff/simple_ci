#!/usr/bin/env bash

REPO=""

SITES_ROOT="/var/www"
BUILDS_ROOT="${SITES_ROOT}/builds"

# MySQL CI user used for all databases.
DB_USER="ci"
DB_PASS="ci_pass"
DB_NAME_LENGTH=20

# Notification settings.
SLACK_CHANNEL="#builds"
SLACK_WEBHOOK=""
SLACK_USERNAME="Build Server"
SLACK_ICON="rocket"

DOMAIN_NAME="example.com"
SITE_TITLE="Site Title"
