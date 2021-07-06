# Docs

## Docker Build

### Give permissions for the entrypoint file

`chmod +x entrypoint.sh`

### Build JMeter base image

`docker build jmeter-base/ -t dishanr/jmeter-base`

### Build JMeter  image with plugins

`docker build jmeter/ -t dishanr/jmeter`

## Docker Run Server

`docker run -dit \
--volume /home/dishanr/Development/jmeter-distributed/jmeter:/jmeter \
--workdir /jmeter dishanr/jmeter --server --jmeterproperty server.rmi.ssl.disable=true`

### Running the load test

`jmeter \
--nongui \
--reportatendofloadtests \
--jmeterproperty server.rmi.ssl.disable=true \
--testfile /home/dishanr/Development/jmeter-distributed/jmeter/test.jmx \
--logfile /home/dishanr/Development/jmeter-distributed/results/results.jtl \
--reportoutputfolder /home/dishanr/Development/jmeter-distributed/results/dashboard \
--jmeterlogfile /home/dishanr/Development/jmeter-distributed/results/logs.log \
--remotestart 172.17.0.3`
