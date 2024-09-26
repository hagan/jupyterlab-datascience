# The path to the directory containging the Makefile.
PROJECT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
makefile_path := $(shell realpath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(shell dirname $(makefile_path))

# Relevant directories within the project repository.
GEOSPATIAL_DIR := $(makefile_dir)/geospatial

GEOSPATIAL_LATEST_DIR := $(GEOSPATIAL_DIR)/latest

DOCKER_USERNAME := hagan

LOCAL_HUB ?= localhost:5000
LOCAL_URI ?= /vice/jupyter
HARBOR_HUB ?= harbor.cyverse.org
HARBOR_URI ?= /vice/jupyter

JLDS_LATEST_DIR := 4.2.5
JLDS_LATEST_SRC_URI := quay.io/jupyter/
JLDS_LATEST_SRC_NAME := datascience-notebook
JLDS_LATEST_SRC_TAG := lab-4.2.5

JLDS_LABEL := jupyterlab-datascience
JLDS_LATEST_LOCAL_DST_URI := /vice/jupyter
JLDS_LATEST_LOCAL_DST_NAME := datascience
JLDS_LATEST_HARBOR_DST_URI := /vice/jupyter
JLDS_LATEST_HARBOR_DST_NAME := datascience
JLDS_LATEST_DST_TAG := 4.2.5


DOCKER_ENV_VARS := \
			--env IPLANT_USER