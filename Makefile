# Makefile for building documentation

default: html

# You can set these variables from the command line.
SRCDIR           := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
JULIAHOME        := $(abspath $(SRCDIR)/..)
include $(JULIAHOME)/Make.inc
JULIA_EXECUTABLE := $(call spawn,$(build_bindir)/julia)

.PHONY: help clean cleanall html pdf deps deploy

help:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo "  html  to make standalone HTML files"
	@echo "  pdf   to make standalone PDF file"
	@echo
	@echo "To run linkcheck, use 'make <target> linkcheck=true'"
	@echo "To run doctests, use 'make <target> doctest=true'"
	@echo "To fix outdated doctests, use 'make <target> doctest=fix'"


DOCUMENTER_OPTIONS := linkcheck=$(linkcheck) doctest=$(doctest)

UnicodeData.txt:
	$(JLDOWNLOAD) http://www.unicode.org/Public/9.0.0/ucd/UnicodeData.txt

deps: UnicodeData.txt
	$(JLCHECKSUM) UnicodeData.txt

clean:
	-rm -rf _build/* deps/* docbuild.log UnicodeData.txt

cleanall: clean

html: deps
	@echo "Building HTML documentation."
	$(JULIA_EXECUTABLE) --color=yes $(call cygpath_w,$(SRCDIR)/make.jl) $(DOCUMENTER_OPTIONS)
	@echo "Build finished. The HTML pages are in _build/html."

pdf: deps
	@echo "Building PDF documentation."
	$(JULIA_EXECUTABLE) --color=yes $(call cygpath_w,$(SRCDIR)/make.jl) -- pdf $(DOCUMENTER_OPTIONS)
	@echo "Build finished."

# The deploy target should only be called in Travis builds
deploy: deps
	@echo "Deploying HTML documentation."
	$(JULIA_EXECUTABLE) --color=yes $(call cygpath_w,$(SRCDIR)/make.jl) -- deploy $(DOCUMENTER_OPTIONS)
	@echo "Build & deploy of docs finished."
