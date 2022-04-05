# prl-dev-env
Local development environment setup for Family private law

## Requirements

This is designed to work on Mac or Linux.

The following packages are required:

    - docker
    - docker-compose
    - azure-cli
    - postgres-client
    - node.js and yarn
    - java 11

Note that a VPN is required as this environment uses multiple services in the AAT environment.

Also, you will need access to azure key vault. Please contact a member of private law team to gain access.

## Set up

If you're running on macOS install the following via brew:

```bash
brew install coreutils azure-cli libpq
brew link --force libpq
brew install --cask docker
```

Make sure that Docker has been given at least **9GB** of RAM.

The init script will clone the prl ccd definition repository into sub-folders, start the CCD services and import the definition file. Then environment will then shut down and be ready for use.

```bash
./bin/init.sh
```

Once everything has started you will be able to use the logins found in the `.env` file for:

* http://localhost:3000 XUI Case manager: login `IDAM_CASEWORKER_USERNAME`/`PASSWORD`

## Usage

Please note that the Java APIs must be assembled with `./gradlew assemble` before starting the environment.

```bash
./bin/start.sh
```

You can then log in to XUI going to `http://localhost:3000/`.

To stop docker containers execute below script. This will bring down all docker containers.

```bash
./bin/stop.sh
```

### Updating the CCD definition file

Import changes to the CCD definition file by running:

```bash
./bin/utils/ccd-import-definition.sh
```
