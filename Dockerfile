FROM tomcat:8-jre8
MAINTAINER nathan@omnimodal.io

RUN apt-get update \
	&& apt-get install -y postgresql-client \
	&& apt-get install -y vim \
	&& apt-get install -y procps

# Install json parser so we can read API key for CreateAPIKey output
RUN wget http://stedolan.github.io/jq/download/linux64/jq
RUN chmod +x ./jq
RUN cp jq /usr/bin/

WORKDIR /
RUN mkdir /usr/local/transitclock
RUN mkdir /usr/local/transitclock/config
RUN mkdir /usr/local/transitclock/db
RUN mkdir /usr/local/transitclock/logs
RUN mkdir /usr/local/transitclock/cache
RUN mkdir /usr/local/transitclock/data
RUN mkdir /usr/local/transitclock/test
RUN mkdir /usr/local/transitclock/test/config

ADD transitclock/target/*.jar /usr/local/transitclock/
ADD transitclockApi/target/api.war $CATALINA_HOME/webapps
ADD transitclockWebapp/target/web.war $CATALINA_HOME/webapps

# replace index.jsp for default web app, redirect to /web
ADD config/redirect.jsp $CATALINA_HOME/webapps/ROOT/index.jsp

ADD config/postgres_hibernate.cfg.xml /usr/local/transitclock/config/hibernate.cfg.xml
ADD config/transitclockConfig.xml /usr/local/transitclock/config/transitclockConfig.xml
ADD config/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.xml
ADD config/logback.development.xml /usr/local/transitclock/config/logback.development.xml
ADD config/logback.production.xml /usr/local/transitclock/config/logback.production.xml
ADD transitclock/src/main/resources/logbackGtfs.xml /usr/local/transitclock/config/logbackGtfs.xml
ADD transitclock/target/classes/ddl_postgres*.sql /usr/local/transitclock/db/

ADD bin/*.sh /

# CMD ["tail", "-f", "/dev/null"]
CMD ["./check_db_up.sh", "./start_transitclock.sh"]
