# python-singleton-demo-app

## Description

This is a demo app written in python with only one service. It has two endpoints:
- / - returns a "hello" message
- /encode/<str> - returns a base64 encoded string of the provided string

## How to run
see [Makefile](Makefile)

```shell
make install-app
```

### generate laod
```shell
make install-loadgen RATE=5000 REPORTING_INTERVAL=60
```