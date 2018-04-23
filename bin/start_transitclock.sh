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
	-Duser.timezone=EST \
	-Dtransitclock.configFiles=/usr/local/transitclock/config/transitclockConfig.xml \
	-Dtransitclock.core.agencyId=$AGENCYID \
	-Dtransitclock.logging.dir=/usr/local/transitclock/logs/ \
	-jar /usr/local/transitclock/Core.jar \
	-configRev 0 > /usr/local/transitclock/logs/output.txt &

tail -f /dev/null
