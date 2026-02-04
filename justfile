# Build project
[group('dev')]
build:
    @echo "Building..."
    @mkdir -p build
    @rm -rf build/debug
    @mkdir -p build/debug
    @odin build src/cmd/ -o:none -debug -out:build/debug/perun

# Build and run project
[group('dev')]
run: build
    @echo "Running...\n"
    @./build/debug/perun

# Prepare openssl and create library wrapper
[group('dev')]
openssl-macos:
    @echo "\nOpenSSL target: macOS\n(Process can take couple minutes)\n"

    @echo "Configuring OpenSSL..."
    @cd external/crypto/openssl && ./Configure darwin64-arm64-cc no-shared > /dev/null || (cat build.log && exit 1)
    @rm -f external/crypto/openssl/build.log
    @echo "Configuring: \033[32mDONE\033[0m\n"

    @echo "Compiling OpenSSL..."
    @cd external/crypto/openssl && make -j$(sysctl -n hw.ncpu) > /dev/null || (cat build.log && exit 1) # @cd external/crypto/openssl && make -j$(nproc) > /dev/null    <- linux version
    @rm -f external/crypto/openssl/build.log
    @echo "Compiling: \033[32mDONE\033[0m\n"

    @echo "Wrapping project specific parts of OpenSSL..."
    @cd external/crypto && zig cc -target aarch64-macos \
                                  -I ./openssl/include \
                                  -c crypto_wrapper.c \
                                  -o crypto_wrapper.o \
                                  || (cat build.log && exit 1)
    @rm -f external/crypto/build.log
    @echo "Wrapping: \033[32mDONE\033[0m\n"

# Build in release mode with all optimizations and additional checks (such as warnings as errors)
[group('deploy')]
release:
    @echo "Releasing..."
    @mkdir -p build
    @rm -rf build/release
    @mkdir -p build/release
    @odin build src/cmd/ -o:speed -microarch:native -vet -vet-semicolon -warnings-as-errors -out:build/release/perun