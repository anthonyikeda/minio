#GOPATH := $(CURDIR)/tmp/gopath
MAKE_OPTIONS := -s

all: getdeps cover install

checkdeps:
	@./checkdeps.sh

getdeps: checkdeps
	@go get github.com/tools/godep && echo "Installing godep"
	@go get golang.org/x/tools/cmd/cover && echo "Installing cover"

build-erasure:
	@$(MAKE) $(MAKE_OPTIONS) -C pkgs/erasure/isal lib
	@godep go test -race -coverprofile=cover.out github.com/minio-io/minio/pkgs/erasure

build-signify:
	@$(MAKE) $(MAKE_OPTIONS) -C pkgs/signify

build-cpu:
	@godep go test -race -coverprofile=cover.out github.com/minio-io/minio/pkgs/cpu

build-sha1:
	@godep go test -race -coverprofile=cover.out github.com/minio-io/minio/pkgs/crypto/sha1/

build-crc32c:
	@godep go test -race -coverprofile=cover.out github.com/minio-io/minio/pkgs/checksum/crc32c

build-split: build-strbyteconv
	@godep go test -race -coverprofile=cover.out github.com/minio-io/minio/pkgs/split

build-strbyteconv:
	@godep go test -race -coverprofile=cover.out github.com/minio-io/minio/pkgs/strbyteconv

build-storage: build-storage-append build-storage-encoded

build-storage-append:
	@godep go test -race -coverprofile=cover.out github.com/minio-io/minio/pkgs/storage/appendstorage

build-storage-encoded:
	@godep go test -race -coverprofile=cover.out github.com/minio-io/minio/pkgs/storage/encodedstorage

cover: build-erasure build-signify build-split build-crc32c build-cpu build-sha1 build-storage
	@godep go test -race -coverprofile=cover.out github.com/minio-io/minio/pkgs/gateway

install: build-erasure
	@godep go install github.com/minio-io/minio/cmd/minio && echo "Installed minio into ${GOPATH}/bin"

save: restore
	@godep save ./...

restore:
	@godep restore

env:
	@godep go env

clean:
	@rm -v cover.out
