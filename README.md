**[Deprecated] Note this repo is no longer maintained, and is archived for historical context only.**

# Data Warehouse for 2 Degrees Investing

This repository is the home for code related to the 2 Degrees Investing Data Warehouse (DW).
Note that this project uses `docker`, which is a tool which allows us to easily package this project, so new collaborators don't need to worry about setup or installation comands, or about tthis project breaking something else on their computer.
For more informattion, ROpenSci has a nice [introduction to docker for `R` users](http://ropenscilabs.github.io/r-docker-tutorial/).

## Starting the containers

To get started with development on this project, and run the import application, simply run on the terminal

```bash
docker-compose up -d
```

This will create two docker containers, one containing a development database (usually called `twodii-datawarehouse_db_1`) and one containing the python application code (`twodii-datawarehouse_app_1`).

## Running the application

Initially, the database is an empty PostgreSQL database.
To apply the twodii-datawarehouse structure to it, we must run the application code in the `app` container.
To enter the app container, run

```bash
docker attach <<name of app container>>
```

Replace `<<name of app container>>` with the container that was started by docker (usually `twodii-datawarehouse_app_1`).
This will put your terminal into the shell _inside_ the docker container, which has all the python code for updating the database and importing data files.
The prompt inside the docker contianer will look somthing like:

```bash
root@2a77e1b22478:/usr/src/app#
```

where the `@2a77e1b22478` component will change, as that is the container's internal ID.
From this prompt run

```bash
# to only create SQL tables and SQL functions
python twodii-datawarehouse.py -v -m
# or
# for SQL creation and importing data files:
python twodii-datawarehouse.py -v
```

Both database migration management and data import are idempotent, meaning that running the same command repeatedly is a safe operation, and will not cause errors.

## Stopping containers

You can exit back to the host shell by pressing `Ctrl + P` then `Ctrl + Q`, which will leave the app container running. or by typing `exit` at the container's prompt, which will stop the app container, but leave the database container running.

To "turn off" the docker containers, from the _host_ shell run:

```bash
docker-compose down
```

## Managing data

The development database is persisted across runs using [docker volumes](https://www.youtube.com/watch?v=p2PH_YPCsis).
The volume can be removed (and all data inside deleted) using

```bash
docker-compose down --volumes
```

The files for importing are exposed to the app conatiner through volume mapping, and on the _host_ file system, they are located in `test/data_files`.
This directory is excluded from git, so you can put files in this directory without worrying about accidentally comitting them.
