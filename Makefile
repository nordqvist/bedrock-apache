IMAGES := dev gc production

BUILDS := $(IMAGES:%=build-%)
RELEASES := $(IMAGES:%=release-%)

.PHONY: build
build: $(BUILDS)
$(BUILDS):
	$(MAKE) -C $(@:build-%=%) build

.PHONY: release
release: $(RELEASES)
$(RELEASES):
	$(MAKE) -C $(@:release-%=%) release
