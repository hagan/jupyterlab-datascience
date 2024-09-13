# Makefile
include config.mk
export

BUILDX_NAME ?= default


reset-docker-mybuilder:
	@docker buildx rm $(BUILDX_NAME)
	@docker buildx create $(BUILDX_NAME) --use


build:
	@echo "Building jupyterlab-datascience docker image"
	@( \
		cd $(makefile_dir)/latest; \
		docker buildx use $(BUILDX_NAME); \
		DOCKER_BUILDKIT=1 docker buildx build --label jupyterlab-datascience --tag localhost:5000/jupyterlab-datascience:latest .; )


run:
	@echo "Running jupyterlab-datascience docker image"
	docker run -p 10000:8888 localhost:5000/jupyterlab-datascience:latest


build-geospatial:
	@echo "Building jupyterlab-datascience geospatial docker image"
	@(cd $(GEOSPATIAL_LATEST_DIR); docker buildx use $(BUILDX_NAME); docker buildx build --label jupyterlab-datascience-geospatial .;)