########################################################
# Makefile configuration
########################################################
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c 
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

########################################################
# GLOBAL VARIABLES
########################################################
NAMESPACE=monitoring
CLUSTER_NAME=staging
CI=argocd               # Valid options are [argocd, flux]
USER=changeme           # admin username cannot be used in gitea see https://gitea.com/gitea/helm-chart/#admin-user
PWD=changeme
        
                        

all:
> $(MAKE) everything >log.txt

create:
> @touch log
> @k3d cluster create $(CLUSTER_NAME)  | tee -a log
.PHONY: setup 


dependencies: 
> @sleep 25s
> @kubectl create namespace $(NAMESPACE) | tee -a log
> @arkade get $(CI) | tee -a log
> @arkade install argocd | tee -a log
.PHONY: dependencies

deploy:
> kustomize build | kubectl apply -f -
.PHONY: deploy

argocd: 
> kubectl wait --for=condition=Ready pods --all -n argocd 
> kubectl port-forward svc/argocd-server -n argocd 8443:443 >/dev/null &
.PHONY: argocd 

clean: 
> @rm log
.PHONY: clean

destroy:
> @k3d cluster delete $(CLUSTER_NAME) | tee -a log
.PHONY: destroy 



converge: create dependencies 
