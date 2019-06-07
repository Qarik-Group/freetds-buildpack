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
