# Makefile
include config.mk
export

BUILDX_NAME ?= default

## GOAL: "make build" -> build latest version of quay.io/jupyter/datascience-notebook:lab-?

# make NOCACHE=yes
ifeq ($(NOCACHE), yes)
	NOCACHETAG := --no-cache
else
	NOCACHETAG :=
endif

# make LOCALBUILD=yes
ifeq ($(LOCALBUILD),yes)
# localhost:5000/datascience:latest
	HUB := $(LOCAL_HUB)
	URI := $(LOCAL_URI)
	JLDS_NAME := $(JLDS_LATEST_LOCAL_DST_NAME)
else
# harbor.cyverse.org/vice/jupyter/datascience:latest
	HUB := $(HARBOR_HUB)
	URI := $(HARBOR_URI)
	JLDS_NAME := $(JLDS_LATEST_HARBOR_DST_NAME)
endif
JLDS_DST_TAG_LATEST := $(HUB)$(URI)/$(JLDS_NAME):latest
JLDS_DST_TAG_FQTN := $(LOCAL_HUB)$(URI)/$(JLDS_NAME):$(JLDS_LATEST_DST_TAG)
JLDS_DOCKER_DST_TAGS := --tag $(JLDS_DST_TAG_LATEST) --tag $(JLDS_DST_TAG_FQTN)

ifeq ($(LOCALMOUNT),yes)
# # VOLMOUNTS := --volume $(IRODS_MOUNT_SRC):$(IRODS_MOUNT_DST)
# 	VOLMOUNTS := --privileged --mount type=bind,source=$(IRODS_MOUNT_SRC),target=$(IRODS_MOUNT_DST)
	IRODS_ENV := --env IRODSFUSE_ENABLED=1
else
# 	VOLMOUNTS :=
	IRODS_ENV :=
endif

.PHONY: local-run-datascience

reset-docker-mybuilder:
	@docker buildx rm $(BUILDX_NAME)
	@docker buildx create $(BUILDX_NAME) --use

build-datascience:
	@echo "Building $(JLDS_NAME):$(JLDS_LATEST_DST_TAG) docker image"
	@echo "tags: $(JLDS_DOCKER_DST_TAGS)"
	@( \
		cd $(makefile_dir)/$(JLDS_LATEST_DIR); \
		pwd; \
		docker buildx use $(BUILDX_NAME); \
		DOCKER_BUILDKIT=1 docker buildx build \
			--label $(JLDS_LABEL) \
			$(NOCACHETAG) \
			$(JLDS_DOCKER_DST_TAGS) \
			.; \
	)

local-build-datascience:
	$(MAKE) LOCALBUILD=yes NOCACHE=yes build-datascience

clean-datascience:
	@echo "Cleaning images out for jupyter-datascience"
	docker rmi $(JLDS_DST_TAG_LATEST) 2>/dev/null || echo "Image pynode:latest has already been removed."
	docker rmi $(JLDS_DST_TAG_FQTN) 2>/dev/null || echo "Image pynode:latest has already been removed."
	@echo "To complete removal, run: docker image prune -a"

local-clean-datascience:
	$(MAKE) LOCALBUILD=yes clean-datascience

run-datascience:
	@echo "Running jupyterlab-datascience docker image"
	docker ps --filter "name=$(JLDS_LABEL)" | grep $(JLDS_LABEL) >/dev/null 2>&1 \
		&& docker exec \
			$(DOCKER_ENV_VARS) \
			-it $(JLDS_LABEL) /usr/bin/bash \
		|| docker run \
			--name $(JLDS_LABEL) \
			$(DOCKER_ENV_VARS) \
			$(IRODS_ENV) \
			-p 10000:8888 \
			$(VOLMOUNTS) \
			--rm -it $(JLDS_DST_TAG_LATEST) /bin/sh

local-run-datascience:
	$(MAKE) LOCALBUILD=yes LOCALMOUNT=yes run-datascience

build-geospatial:
	@echo "Building jupyterlab-datascience geospatial docker image"
	@( \
		cd $(GEOSPATIAL_LATEST_DIR); \
		docker buildx use $(BUILDX_NAME); \
		DOCKER_BUILDKIT=1 docker buildx build \
		--label jupyterlab-datascience-geospatial \
		--tag localhost:5000/jupyterlab-datascience-geospatial:latest .; )

run-geospatial:
	@echo "Running jupyterlab-datascience-geospatial docker image"
	@( \
		cd $(GEOSPATIAL_LATEST_DIR); \
		docker run -p 10000:8888 localhost:5000/jupyterlab-datascience-geospatial:latest; )
