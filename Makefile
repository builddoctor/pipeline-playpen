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
	./bin/dast.sh $(ENV)

junit.xml: zap.xml
	 ./bin/transform.sh

clean:
	rm -rf *.xml build *.html zap.yaml

acceptance:
	docker run -dp 8080:8080 builddoctor/playpen:latest
	sleep 2
	curl http://localhost:8080/
	docker ps | grep -v CONTAINER | awk '{print $1}' | xargs docker kill


.PHONY: image audit lint test check install acceptance
