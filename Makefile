.PHONY: build push install-app uninstall-app install-loadgen uninstall-loadgen

SINGLE_US ?= false
INJECT_ERROR_RATE ?= 0
INJECT_BUSY_WAIT_SECONDS ?= 0
RATE ?= 5
NGINX_RATE_LIMIT ?= 50 # r/s
NGINX_ZONE_SIZE ?= 100 # in mb

NGINX_REQUEST_CPU ?= 100m
NGINX_LIMIT_CPU ?= 100m
NGINX_REQUEST_MEMORY ?= 512Mi
NGINX_LIMIT_MEMORY ?= 512Mi

FRONT_REQUEST_CPU ?= 200m
FRONT_LIMIT_CPU ?= 200m
FRONT_REQUEST_MEMORY ?= 512Mi
FRONT_LIMIT_MEMORY ?= 512Mi


BACK_REQUEST_CPU ?= 100m
BACK_LIMIT_CPU ?= 100m
BACK_REQUEST_MEMORY ?= 512Mi
BACK_LIMIT_MEMORY ?= 512Mi

build:
	echo "start build";
	docker-compose build

push:
	docker-compose push

install-app:
	kubectl get namespace simple-us || kubectl create namespace simple-us
	kubectl label namespace simple-us istio-injection=enabled --overwrite
	@echo SINGLE_US $(SINGLE_US)
	@echo INJECT_BUSY_WAIT_SECONDS $(INJECT_BUSY_WAIT_SECONDS)
	@echo INJECT_ERROR_RATE $(INJECT_ERROR_RATE)
	helm install simple-us -n simple-us helm/simple-us-chart/ \
		--set front.env.SINGLE_US=$(SINGLE_US) \
		--set back.env.INJECT_ERROR_RATE=$(INJECT_ERROR_RATE) \
		--set back.env.INJECT_BUSY_WAIT_SECONDS=$(INJECT_BUSY_WAIT_SECONDS) \
		--set nginx.rateLimit.rate=$(NGINX_RATE_LIMIT) \
		--set nginx.rateLimit.zoneSize=$(NGINX_ZONE_SIZE) \
		--set back.resources.requests.cpu=$(BACK_REQUEST_CPU) \
		--set back.resources.requests.memory=$(BACK_REQUEST_MEMORY) \
		--set back.resources.limits.cpu=$(BACK_LIMIT_CPU) \
		--set back.resources.limits.memory=$(BACK_LIMIT_MEMORY) \
		--set front.resources.requests.cpu=$(FRONT_REQUEST_CPU) \
		--set front.resources.requests.memory=$(FRONT_REQUEST_MEMORY) \
		--set front.resources.limits.cpu=$(FRONT_LIMIT_CPU) \
		--set front.resources.limits.memory=$(FRONT_LIMIT_MEMORY) \
		--set nginx.resources.requests.cpu=$(NGINX_REQUEST_CPU) \
		--set nginx.resources.requests.memory=$(NGINX_REQUEST_MEMORY) \
		--set nginx.resources.limits.cpu=$(NGINX_LIMIT_CPU) \
		--set nginx.resources.limits.memory=$(NGINX_LIMIT_MEMORY) 

install-loadgen:
	@echo RATE $(RATE)
	helm install simple-us-load helm/simple-us-load-chart/ --set loadgen.env.RATE=$(RATE) -n simple-us-load --create-namespace

uninstall-app:
	helm uninstall simple-us -n simple-us

uninstall-loadgen:
	helm uninstall simple-us-load -n simple-us-load

expose-app:
	kubectl port-forward -n simple-us svc/nginx 4040:80 --address 0.0.0.0

status:
	kubectl get ns simple-us && kubectl get pods -n simple-us
	kubectl get ns simple-us-load && kubectl get pods -n simple-us-load


uninstall: uninstall-app uninstall-loadgen

install: install-app install-loadgen