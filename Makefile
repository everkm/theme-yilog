ifneq (, $(shell echo $$DEBUG))
  EKMP = "/Users/dayu/Coder/everkm/everkm2/be/everkm-publish/target/debug/everkm-publish"
else
  EKMP = ./node_modules/.bin/everkm-publish
endif


.PHONY: tag
tag:
	@if [ "$(TAG)" != "" ]; then \
		git tag -f $(TAG); \
		git push -f origin $(TAG); \
	fi

	
dev:
	@echo use ekmp $(EKMP)
	@EVERKM_LOG=info,everkm_publish=debug \
		$(EKMP) serve \
		--work-dir ./demo_posts \
		--dev-dir ./ \
		--listen=0.0.0.0:9081

work:
	@EVERKM_LOG=info \
		$(EKMP) serve \
		--work-dir ./demo_posts \
		--listen=0.0.0.0:9081

build-pages:
	@EVERKM_LOG=info \
		$(EKMP) serve \
		--work-dir ./demo_posts \
		--dev-dir ./ \
		--export

fe-env-init:
	pnpm i

fe-dev:
	pnpm run dev

fe-build:
	pnpm run build

dist: fe-build build-pages

sync-config:
	@cp everkm-theme.yaml demo_posts/_everkm-theme.inc.yaml
	@cp everkm.yaml demo_posts/_everkm.inc.yaml


preview:
	@$(EKMP) web \
		--work-dir dist


package-theme:
	@echo $(EKMP)
	$(EKMP) theme package --dev-dir ./ 


dist-theme: fe-build package-theme
	@if [ ! -d theme/dev ]; then mkdir -p theme/dev; fi
	@if [ -d theme/dev ]; then rm -rf theme/dev/* ; fi
	@cp -r dist/* theme/dev/


bundle-theme: dist-theme
	@cd theme && \
		if [ -d yilog ]; then rm -rf yilog ; fi && \
		mv dev yilog && \
		zip -r yilog.zip ./yilog
