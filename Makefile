.PHONY: build push install-app uninstall-app install-loadgen uninstall-loadgen

SINGLE_US ?= false
INJECT_ERROR_RATE ?= 0.0
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

NAMESPACE ?= simple-us
#simple-us-scale

build:
	echo "start build";
	docker buildx create --name simple-us-app-builder --use;
	docker buildx inspect --bootstrap;
	docker buildx build --platform linux/amd64,linux/arm64 -t saurabhjha1/simple-us-app-back:latest --push ./back-service
	docker buildx build --platform linux/amd64,linux/arm64 -t saurabhjha1/simple-us-app-front:latest --push ./front-service
	docker buildx build --platform linux/amd64,linux/arm64 -t saurabhjha1/simple-us-app-loadgen:latest --push ./loadgen-service


push:
	docker buildx build --platform linux/amd64,linux/arm64 -t saurabhjha1/simple-us-app-back:latest --push ./back-service
	docker buildx build --platform linux/amd64,linux/arm64 -t saurabhjha1/simple-us-app-front:latest --push ./front-service
	docker buildx build --platform linux/amd64,linux/arm64 -t saurabhjha1/simple-us-app-loadgen:latest --push ./loadgen-service


install-app:
	kubectl get namespace ${NAMESPACE} || kubectl create namespace ${NAMESPACE}
	kubectl label namespace ${NAMESPACE} istio-injection=enabled --overwrite
	@echo SINGLE_US $(SINGLE_US)
	@echo INJECT_BUSY_WAIT_SECONDS $(INJECT_BUSY_WAIT_SECONDS)
	@echo INJECT_ERROR_RATE $(INJECT_ERROR_RATE)
	helm install simple-us -n ${NAMESPACE} helm/simple-us-chart/ \
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
	kubectl get namespace ${NAMESPACE}-load || kubectl create namespace ${NAMESPACE}-load
	helm install simple-us-load --namespace=${NAMESPACE}-load helm/simple-us-load-chart/ --set loadgen.env.FRONTEND_SERVICE="http://nginx.${NAMESPACE}.svc.cluster.local" --set loadgen.env.RATE=$(RATE) 

uninstall-app:
	helm uninstall simple-us -n ${NAMESPACE}

uninstall-loadgen:
	helm uninstall simple-us-load -n ${NAMESPACE}-load

expose-app:
	kubectl port-forward -n simple-us svc/nginx 4040:80 --address 0.0.0.0

status:
	kubectl get ns ${NAMESPACE} && kubectl get pods -n ${NAMESPACE}
	kubectl get ns ${NAMESPACE}-load && kubectl get pods -n ${NAMESPACE}-load


uninstall: uninstall-app uninstall-loadgen

install: install-app install-loadgen