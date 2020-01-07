# get all the sql files as dependencies
# use `find` to get all the sql files in the pgTAP test directory
# requirements to run migrations using the python app
sql_deps := $(wildcard sql/*.sql) \
	$(shell find test/pgtap -type f -name '*.sql') \
	app/twodii_datawarehouse.py \
	app/twodii_datawarehouse/migrations.py
# all python files in the app and pytest directories
py_unit_deps := $(shell find app/ -type f -name '*.py') \
	$(shell find test/pytest -type f -name '*.py')

.PHONY: test clean

test: test_pgtap_local test_python_unit_test.log

# -------------------------------- python unit --------------------------------
test_python_unit_test.log: $(py_unit_deps)
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test.yml \
		up \
		--exit-code-from app \
		app \
		| tee test_python_unit_test.log

# ----------------------------------- pgTap -----------------------------------
test_pgtap.log: $(sql_deps)
	# Prepare the test DB
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test_pgtap.yml \
		up \
		--abort-on-container-exit \
		--build \
		--exit-code-from app \
		--force-recreate \
		app \
		| tee test_pgtap.log
	# Run the tests
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test_pgtap.yml \
		up \
		--abort-on-container-exit \
		--build \
		--exit-code-from db_check \
		--force-recreate \
		db_check \
		| tee -a test_pgtap.log

clean_test_pgtap.log: $(sql_deps)
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test_pgtap.yml \
		down \
		--volumes \
		| tee clean_test_pgtap.log

# The targets are split into test_* and test_*_local, because on CI/CD servers,
# we can safely expect that there will not be any volumes on the machine that
# need to be removed, and we do not need to worry about tearing the volume down
# aftwards either. On the local test, we are using ordered make targets to
# ensure that the cleaning step runs before the testing step. We don't need to
# worry about tearing the database down after, since it will be cleaned up
# before the next run.
test_pgtap_local: | clean_test_pgtap.log test_pgtap.log

clean:
	rm *.log
	docker-compose \
		down \
		--volumes \
		--remove-orphans
