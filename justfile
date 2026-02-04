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


# Build in release mode with all optimizations and additional checks (such as warnings as errors)
[group('deploy')]
release:
    @echo "Releasing..."
    @mkdir -p build
    @rm -rf build/release
    @mkdir -p build/release
    @odin build src/cmd/ -o:speed -microarch:native -vet -vet-semicolon -warnings-as-errors -out:build/release/perun
