default: build

VERSION := gc
IMAGE := laravel-apache

.PHONY: build
build:
	docker build -t nordqvist/$(IMAGE):$(VERSION) .

.PHONY: release
release: build
	docker push nordqvist/$(IMAGE):$(VERSION)
