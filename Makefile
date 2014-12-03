test:
	@busted --helper=./pretest.lua

wiki:
	@cat README.md > ./wiki/Home.md
	@lua5.1 genwiki.lua
	@echo "Wiki generated."

mod-nodes:
	@grep -rn -e '["\047][[:alnum:]_][[:alnum:]_]*:[[:alnum:]_][[:alnum:]_]*["\047]' $(moddir) > /tmp/mod-nodes
	@echo "Nodes in $(moddir) output to /tmp/mod-nodes."

.PHONY: test wiki
