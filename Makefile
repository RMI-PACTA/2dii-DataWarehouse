.PHONY: test

test: test_pgtap

test_pgtap:
	# Stop the containers, if they are running
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test_pgtap.yml \
		down \
		--volumes
	# Prepare the test DB
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test_pgtap.yml \
		up \
		--abort-on-container-exit \
		--build \
		--exit-code-from app \
		--force-recreate \
		app
	# Run the tests
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test_pgtap.yml \
		up \
		--abort-on-container-exit \
		--build \
		--exit-code-from db_check \
		--force-recreate \
		db_check
	# Teardown again.
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test_pgtap.yml \
		down \
		--volumes
