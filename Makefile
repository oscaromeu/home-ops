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


all:
> $(MAKE) everything

#create:
#> @touch log
##> @k3d cluster create monitoring | tee -a log
#> @k3d cluster create monitoring --agents 2| tee -a log
#.PHONY: setup 

create:
>	@./tools/scripts/configfile.sh

deploy:
> kustomize build | kubectl apply -f -
.PHONY: deploy

