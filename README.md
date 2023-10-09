# python-singleton-demo-app

## Description

This is a demo app written in python with only three services and one load generator service.

* nginx is a rate limiter

* front has / and /encode/<str> endpoints. front calls back for /encode endpoint. Front does not call back if SINGLE_US is true.

* back has / and /encode/<str> endpoint 


## How to run
see [Makefile](Makefile)

# install
```shell
make install
```

# uninstall
```
make uninstall
```