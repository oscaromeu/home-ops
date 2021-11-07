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
CLUSTER=monitoring
CI=argocd               # Valid options are [argocd, flux]
USER=admon              # admin username cannot be used in gitea see https://gitea.com/gitea/helm-chart/#admin-user
PWD=admon

all:
> $(MAKE) everything >log.txt

create:
> @touch log.txt
> @k3d cluster create monitoring | tee -a log.txt 
.PHONY: setup 


dependencies: 
> @sleep 25s
> @kubectl create namespace monitoring | tee -a log.txt
> @arkade get $(CI) | tee log.txt
> @arkade install gitea --namespace $(NAMESPACE) -u $(USER) -p $(PWD) | tee -a log.txt
> @arkade install argocd --namespace $(NAMESPACE)
.PHONY: dependencies


action: 
#> kubectl wait --for=condition=Ready pods --all -n monitoring
#> kubectl --namespace monitoring port-forward svc/gitea-http 3000:3000 >/dev/null &
#> kubectl port-forward svc/argocd-server -n argocd 8443:443 >/dev/null &
#> ADMON_TOKEN=`curl -XPOST -H "Content-Type: application/json" -ks -d '{"name":"batmon"}' -u admon:admon http://127.0.0.1:3000/api/v1/users/\<username\>/tokens|jq '.sha1'`
#> PASS=$(kubectl get secret argocd-initial-admin-secret \
#>   -n argocd \
#>   -o jsonpath="{.data.password}" | base64 -d)
#> echo $PASS
> curl -X 'POST'\
>   'http://127.0.0.1:3000/api/v1/user/repos'\
>   -u admon:admon\
>   -H 'accept: application/json'\
>   -H 'Content-Type: application/json'\
>   -d '{
>   "auto_init": false,
>   "default_branch": "master",
>   "description": "TODO",
>   "name": "live-infra",
>   "private": false,
>   "template": true,
>   "trust_model": "default"
> }'

.PHONY: action

mytarget:
> { \
  set -e ;\
  msg="header:" ;\
  for i in $$(seq 1 3) ; do msg="$$msg pre_$${i}_post" ; done ;\
  msg="$$msg :footer" ;\
  echo msg=$$msg ;\
  }
.PHONY: mytarget

destroy: clean
> @k3d cluster delete monitoring | tee -a log.txt
.PHONY: destroy 


clean: 
#> @rm log.txt
> @rm -rf /tmp/live-infra
.PHONY: clean

converge: create dependencies 
