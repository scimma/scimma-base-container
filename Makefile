##
## For tagging the container:
##
NAME := scimma/base

TAG  := $(shell git log -1 --pretty=%H || echo MISSING )
IMG  := $(NAME):$(TAG)
LTST := $(NAME):latest

FILES := etc/repos/confluent.repo 

.PHONY: test set-release-tags push clean client server all

all: base

print-%  : ; @echo $* = $($*)

base: Dockerfile $(FILES)
	@if [ ! -z "$$(git status --porcelain)" ]; then echo "Directory is not clean. Commit your changes."; exit 1; fi
	docker build -f $< -t $(IMG) .
	docker tag $(IMG) $(LTST)

set-release-tags:
	@$(eval RELEASE_TAG := $(shell echo $(GITHUB_REF) | awk -F- '{print $$2}'))
	@echo RELEASE_TAG =  $(RELEASE_TAG)
	@$(eval MAJOR_TAG   := $(shell echo $(RELEASE_TAG) | awk -F. '{print $$1}'))
	@echo MAJOR_TAG = $(MAJOR_TAG)
	@$(eval MINOR_TAG   := $(shell echo $(RELEASE_TAG) | awk -F. '{print $$2}'))
	@echo MINOR_TAG = $(MINOR_TAG)

push: set-release-tags
	@(echo $(RELEASE_TAG) | grep -P '^[0-9]+\.[0-9]+\.[0-9]+$$' > /dev/null ) || (echo Bad release tag: $(RELEASE_TAG) && exit 1)
	@eval "echo $$BUILDERCRED" | docker login --username $(BUILDER) --password-stdin
	docker tag $(IMG) $(NAME):$(RELEASE_TAG)
	docker tag $(IMG) $(NAME):$(MAJOR_TAG)
	docker tag $(IMG) $(NAME):$(MAJOR_TAG).$(MINOR_TAG)
	docker push $(NAME):$(RELEASE_TAG)
	docker push $(NAME):$(MAJOR_TAG)
	docker push $(NAME):$(MAJOR_TAG).$(MINOR_TAG)
	docker push $(LTST)
	rm -f $(HOME)/.docker/config.json

clean:
	rm -f *~
	rm -f downloads/*
	if [ -d test/.cache ]; then rm -rf test/.cache; else /bin/true; fi
	if [ -d downloads ]; then  rmdir downloads else /bin/true; fi
