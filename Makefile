test:
	$(call test)
	$(call cov_report,Catbird)
	cd Packages/CatbirdApp; $(call test)
	cd Packages/CatbirdApp; $(call cov_report,CatbirdApp)

release:
	cd Packages/CatbirdApp && swift build -c release
	cp Packages/CatbirdApp/.build/release/catbird ./catbird

archive:
	zip -v catbird.zip catbird LICENSE
	cd Packages/CatbirdApp && zip ../../catbird.zip -r -v start.sh stop.sh Public Resources
	cd Packages/CatbirdAPI && zip ../../catbird.zip -r -v Sources/CatbirdAPI

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
