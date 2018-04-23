#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Create WebAgency.'

/set_config.sh

java -Dtransitclock.db.dbName=$POSTGRES_DB \
	-Dtransitclock.hibernate.configFile=/usr/local/transitclock/config/hibernate.cfg.xml \
	-Dtransitclock.db.dbHost=$POSTGRES_PORT_5432_TCP_ADDR:$POSTGRES_PORT_5432_TCP_PORT \
	-Dtransitclock.db.dbUserName=$POSTGRES_USER \
	-Dtransitclock.db.dbPassword=$PGPASSWORD \
	-Dtransitclock.db.dbType=postgresql \
	-cp usr/local/transitclock/Core.jar org.transitclock.db.webstructs.WebAgency $AGENCYID 127.0.0.1 $POSTGRES_DB postgresql $POSTGRES_PORT_5432_TCP_ADDR $POSTGRES_USER $PGPASSWORD
