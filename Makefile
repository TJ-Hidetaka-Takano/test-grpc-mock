PLATFORM	?= x86_64-linux-gnu
BUILD		?= release

topdir		:= $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
builddir	= $(topdir)/targets/$(PLATFORM)/build
installdir	= $(topdir)/targets/$(PLATFORM)/install

ifeq ($(BUILD),release)
override CMAKEFLAGS		+= -DCMAKE_BUILD_TYPE=MinSizeRel
endif
ifeq ($(BUILD),debug)
override CMAKEFLAGS		+= -DCMAKE_BUILD_TYPE=Debug
override CMAKEFLAGS		+= -DCMAKE_VERBOSE_MAKEFILE=ON
override CMAKEFLAGS		+= -DCMAKE_FIND_DEBUG_MODE=ON
endif
override CMAKEFLAGS		+= -DCMAKE_INSTALL_PREFIX=$(installdir)
override CMAKEFLAGS		+= -DCMAKE_PREFIX_PATH=$(installdir)
override CMAKEFLAGS		+= -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
override CMAKEFLAGS		+= --toolchain $(topdir)/cmake/toolchains/$(PLATFORM).cmake

.PHONY: all client server launch test clean

all: client server

client:
	@echo "Building client ============================="
	cmake -S $(topdir) -B $(builddir) $(CMAKEFLAGS)
	cmake --build $(builddir)
	cmake --install $(builddir)

server:
	@echo "Building server ============================="
	python3 -m grpc_tools.protoc -Isrc --python_out=$(installdir)/bin --grpc_python_out=$(installdir)/bin src/proto/hello.proto
	install -m 755 src/server.py $(installdir)/bin/server.py

launch:
	$(installdir)/bin/server.py &
	sleep 1
	$(installdir)/bin/sample-grpc

$(builddir)/sample-grpc-test:
	cmake -S $(topdir) -B $(builddir) $(CMAKEFLAGS) -DCMAKE_BUILD_TYPE=Debug
	cmake --build $(builddir)

test: $(builddir)/sample-grpc-test
	cmake --build $(builddir) --target test
	# cd $(builddir) && make test
	# ctest --test-dir $(builddir) --output-on-failure

clean:
	rm -rf $(builddir) $(installdir)
