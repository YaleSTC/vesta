# Vesta

## Getting Started

After you have cloned this repo, run this setup script to set up your machine
with the necessary dependencies to run and test this app:

    % ./bin/setup

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

[this script]: https://github.com/thoughtbot/laptop

After running the script, make sure to check the `.env` file to make sure all
required lines are uncommented. After setting up, you can run the application
using Rails server:

    % bin/rails server

Your app will be accessible at:

    [TENANT].lvh.me:3000

Where \[TENANT\] is the subdomain of a given "tenant" or college (by default
this should be set to `silliman`).

## License

Licensed under the [GNU GPLv3](https://gitlab.com/yale-sdmp/vesta/blob/master/LICENSE).
