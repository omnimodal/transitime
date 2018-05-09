#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Import GTFS file.'

/set_config.sh

java -Xmx1024M \
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
	-Dlogback.configurationFile=/usr/local/transitclock/config/logbackGtfs.xml \
	-jar /usr/local/transitclock/GtfsFileProcessor.jar \
	-gtfsUrl $GTFS_URL \
	-maxTravelTimeSegmentLength 400 \
	-storeNewRevs

psql \
	-h $POSTGRES_PORT_5432_TCP_ADDR \
	-p $POSTGRES_PORT_5432_TCP_PORT \
	-U $POSTGRES_USER \
	-d $POSTGRES_DB \
	-c "update activerevisions set configrev=0 where configrev = -1; update activerevisions set traveltimesrev=0 where traveltimesrev = -1;"
