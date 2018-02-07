default: build

VERSION := production
IMAGE := laravel-apache

.PHONY: build
build:
	docker build -t nordqvist/$(IMAGE):latest .

.PHONY: release
release: build
	docker tag nordqvist/$(IMAGE):latest nordqvist/$(IMAGE):$(VERSION)

	docker push nordqvist/$(IMAGE):latest
	docker push nordqvist/$(IMAGE):$(VERSION)
