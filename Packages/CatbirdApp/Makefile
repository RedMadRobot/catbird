test:
	swift test --enable-code-coverage --disable-automatic-resolution
	xcrun llvm-cov report \
		.build/debug/CatbirdAppPackageTests.xctest/Contents/MacOS/CatbirdAppPackageTests \
		-instr-profile=.build/debug/codecov/default.profdata \
		-ignore-filename-regex=".build|Tests"

build:
	swift build

release:
	swift build -c release
	cp ./.build/x86_64-apple-macosx/release/catbird ./catbird

update:
	swift package update

clean:
	swift package clean

lint:
	bundle exec pod spec lint
