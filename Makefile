.DEFAULT_GOAL := help
.PHONY: help get l10n format format-check analyze fix check run-dev run-prod \
	apk-dev apk aab ipa icons splash clean upgrade outdated hooks

help:
	@echo "Available targets:"
	@echo "  get          Fetch dependencies"
	@echo "  l10n         Generate localizations"
	@echo "  format       Format Dart code"
	@echo "  analyze      Run static analysis"
	@echo "  fix          Apply automated fixes"
	@echo "  check        Format check + analyze"
	@echo "  run-dev      Run the dev flavor"
	@echo "  run-prod     Run the prod flavor"
	@echo "  apk-dev      Build dev debug APK"
	@echo "  apk          Build prod release APK"
	@echo "  aab          Build prod release app bundle"
	@echo "  ipa          Build prod release IPA"
	@echo "  icons        Generate launcher icons"
	@echo "  splash       Generate native splash screens"
	@echo "  hooks        Enable git pre-commit hooks"
	@echo "  clean        Clean build artifacts"

get:
	flutter pub get

l10n:
	flutter gen-l10n

format:
	dart format lib

format-check:
	dart format --set-exit-if-changed lib

analyze:
	flutter analyze --no-pub

fix:
	dart fix --apply

check: format-check analyze

run-dev:
	flutter run --flavor dev --target lib/main_dev.dart

run-prod:
	flutter run --flavor prod --target lib/main_prod.dart

apk-dev:
	flutter build apk --debug --flavor dev --target lib/main_dev.dart

apk:
	flutter build apk --release --flavor prod --target lib/main_prod.dart \
		--obfuscate --split-debug-info=build/symbols

aab:
	flutter build appbundle --release --flavor prod --target lib/main_prod.dart \
		--obfuscate --split-debug-info=build/symbols

ipa:
	flutter build ipa --release --flavor prod --target lib/main_prod.dart \
		--obfuscate --split-debug-info=build/symbols

icons:
	dart run flutter_launcher_icons

splash:
	dart run flutter_native_splash:create

hooks:
	git config core.hooksPath .githooks

upgrade:
	flutter pub upgrade --major-versions

outdated:
	flutter pub outdated

clean:
	flutter clean
