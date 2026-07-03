# Bauble — a 1-bit bubble shooter for the Playdate.
#
#   make            build Bauble.pdx
#   make run        build and open in the Playdate Simulator
#   make smoke      instrumented build (autopilot) -> BaubleSmoke.pdx
#   make clean
#
# The smoke build stages source/ with the AUTOPILOT / SMOKE_EASY flags flipped
# on (config.lua ships with them off) so it self-plays for headless checks.

SDK ?= $(HOME)/Developer/PlaydateSDK
PDC ?= pdc
SIMULATOR ?= $(SDK)/bin/Playdate Simulator.app
GAME := Bauble

all: $(GAME).pdx

$(GAME).pdx: source/*.lua source/pdxinfo
	$(PDC) source $(GAME).pdx

run: $(GAME).pdx
	open -a "$(SIMULATOR)" $(GAME).pdx

smoke: build/smoke/source
	$(PDC) build/smoke/source $(GAME)Smoke.pdx

build/smoke/source: source/*.lua source/pdxinfo
	mkdir -p $@
	cp source/* $@/
	sed -i '' 's/^AUTOPILOT = false/AUTOPILOT = true/; s/^SMOKE_EASY = false/SMOKE_EASY = true/' $@/config.lua

clean:
	rm -rf build $(GAME).pdx $(GAME)Smoke.pdx

.PHONY: all run smoke clean
