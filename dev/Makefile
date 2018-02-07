default: build

VERSION := dev
IMAGE := laravel-apache

.PHONY: build
build:
	docker build -t nordqvist/$(IMAGE):$(VERSION) .

.PHONY: release
release: build
	docker push nordqvist/$(IMAGE):$(VERSION)
