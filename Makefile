all:
	@./test.lua

.PHONY: all deps

deps:
	make -C lualib-src

inspect.lua:
	wget https://raw.githubusercontent.com/kikito/inspect.lua/master/inspect.lua
