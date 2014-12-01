test:
	busted --helper=./pretest.lua;

wiki:
	cat README.md > ./wiki/Home.md;
	lua5.1 genwiki.lua;

.PHONY: test wiki
