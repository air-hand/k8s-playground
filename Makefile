CLUSTER := playground-cluster
CONTEXT := k3d-$(CLUSTER)
K3D_IMAGE_TAG := k3d-local:latest
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: show-vars
show-vars:
	@echo "CLUSTER: $(CLUSTER)"
	@echo "CONTEXT: $(CONTEXT)"
	@echo "K3D_IMAGE_TAG: $(K3D_IMAGE_TAG)"
	@echo "MAKEFILE_DIR: $(MAKEFILE_DIR)"

.PHONY: build-image
build-image:
	cd k3d && docker build -t $(K3D_IMAGE_TAG) .

.PHONY: create-cluster
create-cluster: build-image
	mkdir -p $(MAKEFILE_DIR)/volume-ollama && mkdir -p $(MAKEFILE_DIR)/volume-webui
	k3d cluster create $(CLUSTER) --image $(K3D_IMAGE_TAG) \
		--volume $(MAKEFILE_DIR)/volume-ollama:/mnt/data/volume-ollama --volume $(MAKEFILE_DIR)/volume-webui:/mnt/data/volume-webui \
		--gpus=all --api-port 127.0.0.1:6550
	kubectl cluster-info

.PHONY: delete-cluster
delete-cluster:
	k3d cluster delete $(CLUSTER)

.PHONY: stop-cluster
stop-cluster:
	k3d cluster stop $(CLUSTER)

.PHONY: start-cluster
start-cluster:
	k3d cluster start $(CLUSTER)

.PHONY: set-context
set-context:
	kubectx $(CONTEXT)

.PHONY: apply-argocd
apply-argocd: set-context
	CURRENT_BRANCH=$$(git branch --show-current) envsubst < ./argocd/application-set.yaml.tmpl > ./argocd/application-set.yaml && \
	kubectl apply -k ./argocd

.PHONY: port-forward-argocd
port-forward-argocd: set-context
	kubectl port-forward --address 127.0.0.1 svc/argocd-server -n argocd 8443:443

.PHONY: get-initial-passwd
get-initial-passwd: set-context
	kubectl get secret argocd-initial-admin-secret -n argocd \
		-o jsonpath="{.data.password}" | base64 -d

.PHONY: argocd-login
argocd-login:
	argocd login 127.0.0.1:8443

.PHONY: port-forward-open-webui
port-forward-open-webui: set-context
	kubectl port-forward --address 127.0.0.1 svc/open-webui -n deepseek 3000:8080
