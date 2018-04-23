#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Create API key.'

/set_config.sh

java -jar /usr/local/transitclock/CreateAPIKey.jar \
	-c "/usr/local/transitclock/config/transitclockConfig.xml" \
	-d "$API_KEY_DESCRIPTION" \
	-e "$API_KEY_EMAIL" \
	-n "$API_KEY_NAME" \
	-p "$API_KEY_PHONE" \
	-u "$API_KEY_URL"
