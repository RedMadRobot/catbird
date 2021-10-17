test:
	swift test --enable-code-coverage --disable-automatic-resolution
	xcrun llvm-cov report \
		.build/x86_64-apple-macosx/debug/CatbirdPackageTests.xctest/Contents/MacOS/CatbirdPackageTests \
		-instr-profile=.build/x86_64-apple-macosx/debug/codecov/default.profdata \
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
