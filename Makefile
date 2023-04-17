image:
	docker build . -t builddoctor/playpen:latest

audit:
	npm audit

lint:
	npm exec eslint app.js

test:
	npm test

check:
	pip3 install checkov -q
	checkov -d . --quiet

