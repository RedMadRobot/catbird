project:
	swift package generate-xcodeproj --enable-code-coverage --skip-extra-files

test:
	swift test --enable-code-coverage --disable-automatic-resolution

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
	pod spec lint
