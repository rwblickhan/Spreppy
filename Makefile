default: brew mint git

.PHONY: brew mint git

brew:
	brew install mint

mint:
	mint bootstrap

git:
	cp Scripts/pre-push .git/hooks/pre-push
