# Vesta

Welcome to Vesta, a web app that manages the housing process for Yale's
residential colleges.

View on [GitLab](https://gitlab.com/yale-sdmp/vesta).

## Getting Started

After you have cloned this repo, run this script to set up your machine with
the necessary dependencies to run and test this app:

    % ./bin/setup

It assumes you have a machine equipped with certain development tools. If not,
you can set up your machine with [this script]. You may find [Ruby], [Git],
[Postgres], [Bundler], and [Homebrew] (for macOS) most useful. We suggest using
[rbenv] if you need multiple concurrent versions of Ruby installed.

[Ruby]: https://www.ruby-lang.org/en/
[Git]: https://git-scm.com/
[Postgres]: https://www.postgresql.org/
[Bundler]: https://bundler.io/
[Homebrew]: https://brew.sh/
[rbenv]: https://github.com/rbenv/rbenv
[this script]: https://github.com/thoughtbot/laptop

After setting up, you can run the application using Rails server:

    % bin/rails server

Your app will be accessible at:

    [TENANT].lvh.me:3000

Where \[TENANT\] is the subdomain of a given "tenant" or college (by default
this should be set to `silliman`).

## License

Licensed under the [GNU GPLv3](https://gitlab.com/yale-sdmp/vesta/blob/master/LICENSE).

## Support

If you have trouble or questions about this application, email the managers of
the [Student Developer & Mentorship Program](http://yalestc.github.io) at `dev-mgt@yale.edu`.
