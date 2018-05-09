#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Update Travel Times.'

# MM-DD-YYYY
# One argument specifies both the start date and end date. If an additional
# argument is specified it is used as the end date. Otherwise the data is
# processed for just a single day.
cmd="$@"

/set_config.sh

java -Xmx1024M \
	-Dtransitclock.environmentName=development \
	-Duser.timezone=$TIMEZONE \
	-Dtransitclock.core.timezone=$TIMEZONE \
	-Dlogback.timezone=$TIMEZONE \
	-Dlogback.errorEmail=$EMAIL_RECIPIENTS \
	-Dlogback.smtpHost=$SMTP_HOST \
	-Dlogback.smtpUsername=$SMTP_USERNAME \
	-Dlogback.smtpPassword=$SMTP_PASSWORD \
	-Dlogback.cloudWatch.region=$CLOUDWATCH_REGION \
	-Dlogback.cloudWatch.logGroup=/transitclock/$ENVIRONMENT_NAME/$AGENCYNAME \
	-Dtransitclock.cloudwatch.awsAccessKey=$AWS_ACCESS_KEY_ID \
	-Dtransitclock.cloudwatch.awsSecretKey=$AWS_SECRET_ACCESS_KEY \
	-Dtransitclock.cloudwatch.awsEndpoint=$CLOUDWATCH_MONITORING_ENDPOINT \
	-Dtransitclock.core.agencyId=$AGENCYID \
	-Dtransitclock.configFiles=$TRANSITCLOCK_CONFIG \
	-Dtransitclock.logging.dir=/usr/local/transitclock/logs/ \
	-Dlogback.configurationFile=/usr/local/transitclock/config/logback.$ENVIRONMENT_NAME.xml \
	-jar /usr/local/transitclock/UpdateTravelTimes.jar $cmd
