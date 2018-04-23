#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Import GTFS file.'

/set_config.sh

java -Xmx1024M \
	-Dtransitclock.core.agencyId=$AGENCYID \
	-Dtransitclock.configFiles=/usr/local/transitclock/config/transitclockConfig.xml \
	-Dtransitclock.logging.dir=/usr/local/transitclock/logs/ \
	-Dlogback.configurationFile=/usr/local/transitclock/config/logbackGtfs.xml \
	-jar /usr/local/transitclock/GtfsFileProcessor.jar \
	-gtfsUrl $GTFS_URL \
	-maxTravelTimeSegmentLength 400

psql \
	-h $POSTGRES_PORT_5432_TCP_ADDR \
	-p $POSTGRES_PORT_5432_TCP_PORT \
	-U $POSTGRES_USER \
	-d $POSTGRES_DB \
	-c "update activerevisions set configrev=0 where configrev = -1; update activerevisions set traveltimesrev=0 where traveltimesrev = -1;"
