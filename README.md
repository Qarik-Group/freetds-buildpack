# FreeTDS Cloud Foundry buildpack

[FreeTDS](https://www.freetds.org/) is a set of libraries for Unix and Linux that allows your programs to natively talk to Microsoft SQL Server and Sybase databases.

This Cloud Foundry supply buildpack can be used in conjunction with your normal application buildpack (`ruby_buildpack` for example), to allow dependencies to be installed that require TinyTDS (the Ruby `tiny_tds` rubygem for example).

Without this buildpack, your application deployment to Cloud Foundry might fail with an error like:

```plain
  Installing tiny_tds 2.1.2 with native extensions
  Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
...
Failed! Do you have FreeTDS 0.95.80 or higher installed?
...
  In Gemfile:
    tiny_tds
  **ERROR** Unable to install gems: exit status 5
```

## Usage

Simple add `freetds_buildpack` or `https://github.com/starkandwayne/freetds-buildpack` to the start of your `manifest.yml` buildpacks list.

For example, from `fixtures/rubyapp/manifest.yml`:

```yaml
applications:
- name: rubyapp
  buildpacks:
  - freetds_buildpack
  - ruby_buildpack
```

If you use `freetds_buildpack` then your Cloud Foundry administrator will need to install the `freetds_buildpack` using `cf create-buildpack`.

If you cannot get a Cloud Foundry administrator to do this, then use the Git URL:

```yaml
applications:
- name: rubyapp
  buildpacks:
  - https://github.com/starkandwayne/freetds-buildpack
  - ruby_buildpack
```

## Buildpack Developer Documentation

To build this buildpack, run the following command from the buildpack's directory:

1. Source the .envrc file in the buildpack directory.

    ```bash
    source .envrc
    ```

    To simplify the process in the future, install [direnv](https://direnv.net/) which will automatically source .envrc when you change directories.

1. Install buildpack-packager

    ```bash
    ./scripts/install_tools.sh
    ```

1. Build the buildpack

    ```bash
    buildpack-packager build -stack cflinuxfs3 -cached
    ```

1. Use in Cloud Foundry

    Upload the buildpack to your Cloud Foundry.

    ```bash
    cf create-buildpack freetds_buildpack freetds_buildpack-*.zip 100
    cf push -p fixtures/rubyapp -f fixtures/rubyapp/manifest.yml
    ```

### Testing

Buildpacks use the [Cutlass](https://github.com/cloudfoundry/libbuildpack/cutlass) framework for running integration tests.

To test this buildpack, run the following command from the buildpack's directory:

1. Source the .envrc file in the buildpack directory.

    ```bash
    source .envrc
    ```

    To simplify the process in the future, install [direnv](https://direnv.net/) which will automatically source .envrc when you change directories.

1. Run integration tests

    ```bash
    ./scripts/integration.sh
    ```

    To run integration tests against CFDev:

    ```bash
    cf login -a https://api.dev.cfdev.sh --skip-ssl-validation -u admin -p admin
    CUTLASS_SCHEMA=https CUTLASS_SKIP_TLS_VERIFY=true ./scripts/integration.sh
    ```

    More information can be found on Github [cutlass](https://github.com/cloudfoundry/libbuildpack/cutlass).

### Reporting Issues

Open an issue on this project.