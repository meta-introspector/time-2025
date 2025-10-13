all: doit test-rnix-dump test-nar-exporter test-binstore-locator

doit: test-rnix-dump test-nar-exporter test-binstore-locator

.PHONY: test-rnix-dump
test-rnix-dump:
	nix build ./000_rnix_dump

.PHONY: test-nar-exporter
test-nar-exporter:
	nix build .#nar-exporter

.PHONY: test-binstore-locator
test-binstore-locator:
	nix build .#binstore-locator
