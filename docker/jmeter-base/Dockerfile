FROM alpine

ARG JMETER_VERSION="5.4.1"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_DOWNLOAD_URL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

ARG TZ="Europe/Amsterdam"
ENV TZ ${TZ}
RUN    apk update \
    && apk upgrade \
    && apk add ca-certificates \
    && update-ca-certificates \
    && apk add --update openjdk8-jre tzdata curl unzip bash \
    && apk add --no-cache nss \
    && apk add --no-cache bash \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /tmp/dependencies  \
    && curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
    && mkdir -p /opt  \
    && tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
    && rm -rf /tmp/dependencies \
    && apk add --update --no-cache python3

ENV PATH $PATH:${JMETER_HOME}/bin
ENV PATH $PATH:${JMETER_HOME}/lib/ext/

COPY entrypoint.sh /

RUN ["chmod", "+x", "entrypoint.sh"]

WORKDIR    ${JMETER_HOME}

ENTRYPOINT ["sh", "entrypoint.sh"]