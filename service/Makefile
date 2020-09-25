clean:
	rm -rf output

tidy:
	go get -u ./...
	go mod tidy

prepare:
	go get ./...

test: prepare check
	go test ./...			

check: prepare
	terraform validate
	golangci-lint run --allow-parallel-runners

build: prepare test clean
	./build.sh

plan: build
	terraform plan

deploy: build
	terraform apply -auto-approve

destroy: build
	terraform destroy			