FROM dishanr/jmeter-base

# Adding plugins to JMeter Docker image
# https://github.com/Azure-Samples/jmeter-aci-terraform/blob/main/docs/adding-jmeter-plugins.md

# https://jmeter-plugins.org/wiki/TestPlanCheckTool/
RUN wget https://jmeter-plugins.org/files/packages/jpgc-plancheck-2.4.zip
RUN unzip -o jpgc-plancheck-2.4.zip -d ${JMETER_HOME}

# https://jmeter-plugins.org/wiki/ConcurrencyThreadGroup/
RUN wget https://jmeter-plugins.org/files/packages/jpgc-casutg-2.9.zip
RUN unzip -o jpgc-casutg-2.9.zip -d ${JMETER_HOME}

# https://jmeter-plugins.org/wiki/ThroughputShapingTimer/
RUN wget https://jmeter-plugins.org/files/packages/jpgc-tst-2.5.zip
RUN unzip -o jpgc-tst-2.5.zip -d ${JMETER_HOME}

ENTRYPOINT ["/entrypoint.sh"]
