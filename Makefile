image:
	docker build . -t builddoctor/playpen:latest

audit:
	npm audit

lint:
	npm exec eslint app.js

check:
	pip3 install checkov -q
	checkov -d .

