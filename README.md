# FreeTDS Cloud Foundry buildpack

[FreeTDS](https://www.freetds.org/) is a set of libraries for Unix and Linux that allows your programs to natively talk to Microsoft SQL Server and Sybase databases.

This Cloud Foundry supply buildpack can be used in conjunction with your normal application buildpack (`ruby_buildpack` for example), to allow dependencies to be installed that require TinyTDS (the Ruby `tiny_tds` rubygem for example).
