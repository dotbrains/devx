.PHONY: help new-version list-versions

help:
	@echo "API Version Management"
	@echo ""
	@echo "Commands:"
	@echo "  make new-version VERSION=v2    Create new API version"
	@echo "  make list-versions              List all API versions"
	@echo "  make test-version VERSION=v1    Test specific version"
	@echo "  make run                        Run development server"

new-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION required. Usage: make new-version VERSION=v2"; \
		exit 1; \
	fi
	@if [ -d "versions/$(VERSION)" ]; then \
		echo "Error: Version $(VERSION) already exists"; \
		exit 1; \
	fi
	@echo "Creating new API version: $(VERSION)"
	@mkdir -p versions/$(VERSION)/routes
	@cp -r versions/v1/* versions/$(VERSION)/
	@echo '"""' > versions/$(VERSION)/__init__.py
	@echo "API Version $(VERSION)" >> versions/$(VERSION)/__init__.py
	@echo '"""' >> versions/$(VERSION)/__init__.py
	@echo "" >> versions/$(VERSION)/__init__.py
	@echo "from .router import router" >> versions/$(VERSION)/__init__.py
	@echo "" >> versions/$(VERSION)/__init__.py
	@echo '__all__ = ["router"]' >> versions/$(VERSION)/__init__.py
	@echo ""
	@echo "✓ Created versions/$(VERSION)/"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Modify versions/$(VERSION)/routes/ as needed"
	@echo "  2. Update app.py to include $(VERSION)"
	@echo "     from .versions import v1, $(VERSION)"
	@echo "     app.include_router($(VERSION).router, prefix=\"/api/$(VERSION)\")"
	@echo "  3. Create migration guide in docs/migrations/"

list-versions:
	@echo "Available API versions:"
	@ls -d versions/v* 2>/dev/null | sed 's/versions\//  - /g' || echo "  No versions found"

test-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION required. Usage: make test-version VERSION=v1"; \
		exit 1; \
	fi
	@echo "Testing API $(VERSION)..."
	pytest tests/test_$(VERSION).py -v

run:
	@echo "Starting FOSS API..."
	./run.sh
