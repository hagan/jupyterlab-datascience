# The path to the directory containging the Makefile.
PROJECT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
makefile_path := $(shell realpath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(shell dirname $(makefile_path))

# Relevant directories within the project repository.
GEOSPATIAL_DIR := $(makefile_dir)/geospatial

GEOSPATIAL_LATEST_DIR := $(GEOSPATIAL_DIR)/latest