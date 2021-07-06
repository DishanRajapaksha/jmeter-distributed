# JMeter Distributed


## Structure


### Docker

#### Contains dockerfiles to build a container with jmeter preinstalled

#### `jmeter-base` dockerfile installs jmeter with a given version

#### `jmeter` dockerfile extends the base image with additional plugins


### Terraform

#### Terraform scripts to create a jmeter load test environment on demand. Specifications such as the number of workers, worker machine sizes, test files and more can be given as inputs


### Pipelines

#### Contains an Azure Pipeline to run the load test in on-demand Azure Containers. Terraformed infrastructure will be destroyed at the end of the load test


### Scripts

#### A Python script to convert jtl results file to junit


## References

[Load Testing Pipeline with JMeter, ACI and Terraform](https://github.com/Azure-Samples/jmeter-aci-terraform)

[JMeter Remote Testing](https://jmeter.apache.org/usermanual/remote-test.html)

[Make Use of Docker with JMeter](https://www.blazemeter.com/blog/make-use-of-docker-with-jmeter-learn-how)