# Convenience targets for the UNO Q Home Assistant voice hub.
# Usage: make up | down | logs | ha-logs | pull | camera-up | satellite-*

COMPOSE ?= docker compose

.PHONY: up down restart logs ha-logs pull camera-up camera-down config \
        satellite-install satellite-run

up:            ## Start core stack (HA + Whisper + Piper + openWakeWord)
	$(COMPOSE) up -d

down:          ## Stop the core stack
	$(COMPOSE) down

restart:       ## Restart the core stack
	$(COMPOSE) restart

logs:          ## Tail all container logs
	$(COMPOSE) logs -f

ha-logs:       ## Tail Home Assistant logs
	$(COMPOSE) logs -f homeassistant

pull:          ## Pull latest images
	$(COMPOSE) pull

config:        ## Validate the compose file
	$(COMPOSE) config

camera-up:     ## Start the optional USB camera (go2rtc)
	$(COMPOSE) --profile camera up -d go2rtc

camera-down:   ## Stop the USB camera
	$(COMPOSE) stop go2rtc

satellite-install:  ## Install the native wyoming-satellite
	./wyoming-satellite/install.sh

satellite-run:      ## Run the satellite in the foreground (test)
	./wyoming-satellite/run.sh
