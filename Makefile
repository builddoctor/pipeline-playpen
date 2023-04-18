image:
	docker build . -t builddoctor/playpen:latest

audit: install
	npm audit

lint: install
	npm exec eslint app.js

test:
	npm test

check:
	pip3 install checkov -q
	checkov -d . --quiet

install:
	npm install

.PHONY: image audit lint test check install
