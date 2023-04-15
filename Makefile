image:
	docker build . -t builddoctor/playpen:latest

audit:
	npm audit

lint:
	npm exec eslint app.js

