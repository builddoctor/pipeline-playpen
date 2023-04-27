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

clean:
	rm -f zap.xml

.PHONY: image audit lint test check install
