CLUSTER := playground-cluster
CONTEXT := kind-$(CLUSTER)

.PHONY: setup-cluster
setup-cluster:
	kind create cluster --name $(CLUSTER)

.PHONY: set-context
set-context:
	kubectx $(CONTEXT)

.PHONY: setup-argocd
setup-argocd: set-context
	kubectl create namespace argocd || true
	curl -fsSL https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml \
	| kubectl apply -n argocd -f -

.PHONY: port-forward
port-forward: set-context
	kubectl port-forward svc/argocd-server -n argocd 8443:443

.PHONY: get-initial-passwd
get-initial-passwd: set-context
	kubectl get secret argocd-initial-admin-secret -n argocd \
		-o jsonpath="{.data.password}" | base64 -d

.PHONY: apply-argocd
apply-argocd: set-context
	kubectl apply -f argocd/application-set.yaml -n argocd

.PHONY: argocd-login
argocd-login:
	argocd login localhost:8443
