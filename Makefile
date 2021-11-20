test:
	$(call test)
	$(call cov_report,Catbird)
	cd Packages/CatbirdApp; $(call test)
	cd Packages/CatbirdApp; $(call cov_report,CatbirdApp)
build:
	swift build

release:
	cd Packages/CatbirdApp; swift build -c release
	cd Packages/CatbirdApp; cp ./.build/release/catbird ./catbird

update:
	swift package update

clean:
	swift package clean

lint:
	bundle exec pod spec lint

define test
    swift test --enable-code-coverage --disable-automatic-resolution
endef

define cov_report
    xcrun llvm-cov report \
		.build/debug/$(1)PackageTests.xctest/Contents/MacOS/$(1)PackageTests \
		-instr-profile=.build/debug/codecov/default.profdata \
		-ignore-filename-regex=".build|Tests"
endef