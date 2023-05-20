image:
	docker build . -t builddoctor/playpen:latest

audit: install
	npm audit

lint: install
	npm exec eslint src

build:
	mkdir -p build

test: build
	npm test

check:
	pip3 install checkov -q
	checkov -d . --quiet

install:
	npm install

zap.xml:
	./dast.sh test

junit.xml: zap.xml
	 ./transform.sh

clean:
	rm -rf *.xml build

acceptance:
	docker run -dp 8080:8080 builddoctor/playpen:latest
	sleep 2
	curl http://localhost:8080/
	docker ps | grep -v CONTAINER | awk '{print $1}' | xargs docker kill


.PHONY: image audit lint test check install acceptance
