.PHONY: setup
setup: helm-dependencies provision-kind-1 provision-kind-2 setup-lb-kind-1 setup-lb-kind-2 setup-helm-kind-1 setup-helm-kind-2

.PHONY: setup-with-cli
setup-with-cli: provision-kind-1 provision-kind-2 setup-lb-kind-1 setup-lb-kind-2 setup-cilium-cli

.PHONY: provision
provision: provision-kind-1 provision-kind-2

.PHONY: provision-kind-1
provision-kind-1:
	./provision.sh "kind-1"

.PHONY: provision-kind-2
provision-kind-2:
	./provision.sh "kind-2"

.PHONY: setup-helm-kind-1
setup-helm-kind-1:
	./setup-cilium.sh kind-1

.PHONY: setup-helm-kind-2
setup-helm-kind-2:
	./setup-cilium.sh kind-2

.PHONY: setup-cilium-cli
setup-cilium-cli:
	./setup-cilium-with-cli.sh

.PHONY: setup-lb-kind-1
setup-lb-kind-1:
	./setup-metallb.sh kind-1

.PHONY: setup-lb-kind-2
setup-lb-kind-2:
	./setup-metallb.sh kind-2

.PHONY: destroy
destroy: destroy-kind-1 destroy-kind-2

.PHONY: destroy-kind-1
destroy-kind-1:
	kind delete cluster --name=kind-1

.PHONY: destroy-kind-2
destroy-kind-2:
	kind delete cluster --name=kind-2

.PHONY: helm-dependencies
helm-dependencies:
	helm repo add cilium https://helm.cilium.io/
	helm repo update

.PHONY: test-connectivity
test-connectivity:
	cilium connectivity test --context kind-kind-1 --multi-cluster kind-kind-2