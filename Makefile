image:
	docker build . -t builddoctor/playpen:latest

audit: install
	npm audit

lint: install
	npm exec eslint src

test:
	npm test

check:
	pip3 install checkov -q
	checkov -d . --quiet

install:
	npm install

junit.xml: zap.xml
	 ./transform.sh

clean:
	rm -f *.xml

.PHONY: image audit lint test check install
