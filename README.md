gd-agent
========

fluent output plugin to send beacons to grepdata via HTTP GET/POST. At the current time, POST only supports one beacon at a time.

## Requirements

+ **ruby (1.9.2 or greater)**
On Ubuntu, you can use "sudo apt-get install ruby1.9.3"

+ **fluentd**
If you haven't installed fluentd, please refer the documentation at http://fluentd.org, I prefer using the packaged installation i.e. yum, apt etc. over pure gem installation since those come with a stable release and init scripts

## Configuration

###Input Plugin
The input plugin is a test plugin which is specific to logging done by the grepdata query API. It cannot be used as-is unless and until you use logback-access for log formatting.

###Ouput Plugin
```
<match {tag}>
  url http://beacon.grepdata.com/v1
  type out-gd-http
  http_method get
  token {YOUR_TOKEN_GOES_HERE}
  endpoint {YOUR_ENDPOINT_GOES_HERE}
</match>
```

+ **url:** Do not change this. It denotes the http endpoint for the grepdata api that accepts beacons.
+ **type:** Do not change this. It denotes the name of the fluentd plugin.
+ **http_method:** get or post. 
+ **token:** The token from your GrepData account settings.
+ **endpoint:** The endpoint to which you want to send this data. Do not switch endpoints and avoid sending test data to your prod endpoints or it will pollute your analytics.

## About Us
GrepData is an analytics platform that changes the traditional data warehousing paradigm. Our data collection APIs collect data from various sources i.e. client-side, server-side and allow you to do query-time transformations on top of your data.

Example:

+ If you send age as a paramter in your beacons, most analytics providers will let you view the age as-is.
+ GrepData analytics allows you to view the age as-is just like others, but at the same allows you to write custom transformations to bucketize age into different buckets at query time.
+ You can create a marketing_age_bucket (i.e. 17 and under, 18-25, 26-40, 40+) to satisfy your marketing team needs.
+ Or you can create a sales_age_bucket (i.e. 13 and under, 14-21, 22 - 40, 40 - 60, 60+) to satisfy your sales team needs.
+ All of this can be done without writing a single line of code.
+ We also allow processing time transformations and allow users to build their own OLAP cubes. You can run query time transforms on top of the same OLAP cubes.
