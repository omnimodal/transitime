#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Start TheTransitClock.'

/set_config.sh

rmiregistry &

#set the API as an environment variable so we can set in JSP of template/includes.jsp in the transitime webapp
export APIKEY=$(/get_api_key.sh)

# make it so we can also access as a system property in the JSP
export JAVA_OPTS="$JAVA_OPTS -Dtransitclock.apikey=$(/get_api_key.sh)"

echo JAVA_OPTS $JAVA_OPTS

# similar thing for tomcat credentials
export CATALINA_OPTS="$CATALINA_OPTS -Dwebapp.user=$WEBAPP_USER -Dwebapp.password=$WEBAPP_PASSWORD"

/usr/local/tomcat/bin/startup.sh

nohup java -Xss12m \
	-Dtransitclock.environmentName=$ENVIRONMENT_NAME \
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
	-Dlogback.configurationFile=/usr/local/transitclock/config/logback.$ENVIRONMENT_NAME.xml \
	-Dtransitclock.core.agencyId=$AGENCYID \
	-Dtransitclock.logging.dir=/usr/local/transitclock/logs/ \
	-Dtransitclock.monitoring.avlFeedEmailRecipients=$EMAIL_RECIPIENTS \
	-Dtransitclock.monitoring.emailRecipients=$EMAIL_RECIPIENTS \
	-Dtransitclock.schedBasedPreds.pollingRateMsec=$SCHED_BASED_PREDS_POLLING_RATE_MSEC \
	-Dtransitclock.configFiles=/usr/local/transitclock/config/transitclockConfig.xml \
	-jar /usr/local/transitclock/Core.jar \
	-configRev 0 > /usr/local/transitclock/logs/output.txt &

tail -f /dev/null
