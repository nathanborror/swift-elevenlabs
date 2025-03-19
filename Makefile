main:
	@swift build
	@cp .build/debug/CLI elevenlabs
	@chmod +x elevenlabs
	@echo "Run the program with ./elevenlabs"
