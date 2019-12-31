.PHONY: test

test: test_pgtap_local

test_pgtap:
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

# The targets are split into test_* and test_*_local, because on CI/CD servers,
# we can safely expect that there will not be any volumes on the machine that
# need to be removed, and we do not need to worry about tearing the volume down
# aftwards either.
test_pgtap_local:
	# Stop the containers, if they are running
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test_pgtap.yml \
		down \
		--volumes
	# Actually prepare and run the tests
	make test_pgtap
	# Teardown again.
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test_pgtap.yml \
		down \
		--volumes
