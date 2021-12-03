PACKAGE_PATH = Packages/CatbirdApp
BUILD_CATBIRD_APP = swift build \
	--disable-sandbox \
	--configuration release \
	--package-path $(PACKAGE_PATH)

test-api:
	swift test --enable-code-coverage
	$(call cov_report,Catbird)

test-app:
	swift test --enable-code-coverage --disable-automatic-resolution --package-path $(PACKAGE_PATH)
	cd $(PACKAGE_PATH) && $(call cov_report,CatbirdApp)

test: test-api test-app

release:
	$(BUILD_CATBIRD_APP)
	cp $(shell $(BUILD_CATBIRD_APP) --show-bin-path)/catbird ./catbird

archive:
	zip -v catbird.zip catbird LICENSE
	cd $(PACKAGE_PATH) && zip ../../catbird.zip -r -v start.sh stop.sh Public Resources
	cd Packages/CatbirdAPI/ && zip ../../catbird.zip -r -v Sources/CatbirdAPI

update:
	swift package update --package-path $(PACKAGE_PATH)

clean:
	swift package clean
	swift package clean --package-path $(PACKAGE_PATH)

lint:
	bundle exec pod spec lint

define cov_report
    xcrun llvm-cov report \
		.build/debug/$(1)PackageTests.xctest/Contents/MacOS/$(1)PackageTests \
		-instr-profile=.build/debug/codecov/default.profdata \
		-ignore-filename-regex=".build|Tests"
endef
