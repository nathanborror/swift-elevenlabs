main:
	@swift build
	@cp .build/debug/ElevenLabsCLI elevenlabs
	@chmod +x elevenlabs
	@echo "Run the program with ./elevenlabs"
