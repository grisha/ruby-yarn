# Ruby-Yarn

This is a gem for accessing tha [Hadoop Yarn REST API](https://hadoop.apache.org/docs/r2.4.1/hadoop-yarn/hadoop-yarn-site/WebServicesIntro.html)
It basically wraps it in rest-client and hashie.

It can detect that an RM is in Standby mode (in a HA setup) and will
automatically retry on the Active RM.

There is no support for authentication (yet - PR's welcome!). No tests
either.

## Installation

Add this line to your application's Gemfile (until I actually publish this):

    gem 'ruby-yarn', :git => 'https://github.com/grisha/ruby-yarn.git'

## Usage

```ruby
require 'ruby-yarn'
```

### Resource Manager API

```ruby
rm = RubyYarn::Cluster.new('http://resource-manager-host.example.com:8088/ws/v1')

# nodes
nodes  = rm.nodes # nodes is an array of [Mashes](https://github.com/intridea/hashie)
nodes.first  #<RubyYarn::Cluster::Node availMemoryMB=233984 healthReport=""...
nodes.first.availMemoryMB # 233984
nodes.first.id # node1.example.com:35782

node = rm.node(node_id) # if you know the node id

# cluster metrics
rm.metrics #<RubyYarn::Cluster::ClusterMetrics activeNodes=234 allocatedMB=92569654 appsCompleted=130264 ...

# scheduler
rm.scheduler #<RubyYarn::Cluster::ClusterScheduler rootQueue=#<RubyYarn::Cluster::ClusterScheduler childQueues= ...
rm.scheduler.type # fairScheduler

# applications
rm.apps(states: 'running,accepted', limit: 3)

# appstatistics
rm.appstatistics(states: 'running,accepted', applicationTypes: 'mapreduce')

# specific app by id
rm.app(app_id)

# app attempts
rm.apps(states: 'running', limit: 3).first.attempts
```

### Node Manager API

```ruby
nm = RubyYarn::NodeManager.new('http://datanode23.example.com:8042/ws/v1')
nm.info # #<RubyYarn::NodeManager::Info hadoopBuildVersion="2.3.0-cdh5.1.0 ...

# apps on that node
apps = nm.apps
app = nm.app(app_id) # specific app by id

# containers on the node
cons = nm.containers
con =  nm.container(cons.first.id)
```

### Map Reduce API

```ruby
# you need to know the app id to get M/R information in Yarn
app_id = rm.apps.first
mr = RubyYarn::MapReduce.new("http:///resource-manager-host.example.com:8088/proxy/#{app_id}/ws/v1")

jobs = mr.jobs
job = mr.job(jobs.first.id) # by id

tasks = job.tasks
task = job.task(tasks.first.id) # by id

counters = task.counters

attempts = task.attempts
attempt = task.attempt(attempts.first.id)
attempt_counters = task.attempts.first.counters
```

### History Server API

```ruby

hs = RubyYarn::History.new("http://history-host.example.com:19888/ws/v1/history")
puts hs.info

jobs =  hs.mapreduce_jobs(limit: 5)
job = hs.mapreduce_job(jobs.first.id)

# from here on it's same as the MapReduce:
attemptss = job.attemps
# etc...
```
