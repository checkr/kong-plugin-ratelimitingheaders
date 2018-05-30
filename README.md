# Kong plugin - ratelimitingheaders

## Introduction

Example of the spec of Checkr's rate limiting: https://docs.checkr.com/#rate_limiting

This plugin transform the standard Kong's rate limiting to match Checkr's spec.

```
X-RateLimit-Limit-Minute: 10
X-RateLimit-Remaining-Minute: 9

=>

X-Ratelimit-Limit: 10
X-Ratelimit-Remaining: 9
X-Ratelimit-Reset: 2018-02-02T16:39:00Z
```

Here's the config setting.

```
config.rate_limit_time_unit -> specified time unit of the rate limiting, default: minute
```

## Development

Follow https://github.com/Kong/kong-vagrant to setup kong-vagrant.

```
$ git clone https://github.com/Kong/kong-vagrant
$ cd kong-vagrant

# clone the Kong repo (inside the vagrant one)
$ git clone https://github.com/Kong/kong

# clone this plugin
$ git clone https://github.com/checkr/kong-plugin-ratelimitingheaders

# build a box with a folder synced to your local Kong and plugin sources
$ KONG_PLUGIN_PATH=ratelimitingheaders vagrant up

# ssh into the Vagrant machine, and setup the dev environment
$ vagrant ssh
$ cd /kong
$ make dev
$ export KONG_CUSTOM_PLUGINS=ratelimitingheaders

# startup kong: while inside '/kong' call `kong` from the repo as `bin/kong`!
# we will also need to ensure that migrations are up to date
$ cd /kong
$ bin/kong migrations up
$ bin/kong start
```

To test this plugin.

```
$ cd /kong
$ bin/busted /kong-plugin/spec
```
