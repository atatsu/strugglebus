test:
	@busted --helper=./pretest.lua

wiki:
	@cat README.md > ./wiki/Home.md
	@lua5.1 genwiki.lua
	@echo "Wiki generated."

mod-nodes:
	@grep -rn -e '["\047][[:alnum:]_][[:alnum:]_]*:[[:alnum:]_][[:alnum:]_]*["\047]' $(moddir) | \
		sed -r 's/([[:alnum:]/._-]+):([0-9]+).*["\047]([[:alnum:]_]+:[[:alnum:]_]+)["\047].*/\3 \1:\2/' | \
		sort | column -t 

.PHONY: test wiki mod-nodes
