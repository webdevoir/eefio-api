# Ethio API

**A RESTful API for the Ethereum blockchain, powered by Rails**

- Production: [api.ethio.app](https://api.ethio.app)
- Staging: [staging.api.ethio.app](https://staging.api.ethio.app)

<!-- [![Build Status](https://travis-ci.org/sandstormco/ethio-api.svg?branch=master)](https://travis-ci.org/sandstormco/ethio-api) -->
<!-- [![Maintainability](https://api.codeclimate.com/v1/badges/22ef4ea6475be7057b87/maintainability)](https://codeclimate.com/github/sandstormco/ethio-api/maintainability) -->


## Development Setup

**tl;dr**

[Strap your computer](https://macos-strap.herokuapp.com), first (macOS only. Windows/Linux… ask a friend?).

```bash
git clone https://github.com/sandstormco/ethio-api.git
cd ethio-api
./script/setup
./script/server
```


## Scripts to Rule Them All

Ethio repos use the [Scripts to Rule Them All](http://githubengineering.com/scripts-to-rule-them-all) pattern.
See also: https://github.com/github/scripts-to-rule-them-all

`/script` is a collection of scripts for development on an OS X / macOS computer.
Development setup on a Windows or Linux computer may vary.

## Development Scripts

The rest of these instructions assume that you’ve [strapped your computer](https://macos-strap.herokuapp.com) already. If you haven’t, you’ll need to install somethings manually. (But really, you’re better off using [Strap](https://macos-strap.herokuapp.com).)

- [Homebrew](http://brew.sh)
- Homebrew taps and extensions
- Xcode command line tools
- Postgres launchctl (for `setup` script)

### Bootstrap script

The `bootstrap` script is the first time development environment configuration for this app.
You should only need to run this script once.
It will install the proper Ruby and PostgreSQL database versions.

Clone this repo.

```bash
git clone git@github.com:quantstamp/app-www.git
cd website
```

Then run the `bootstrap` script.

```bash
./script/bootstrap
```

### Setup script

After you’ve `bootstrap`ed, you’ll need to `setup`.
The `setup` setups the Rails environment (creates, migrates and seeds databases, then clears `logs` and `tmp`).

```bash
./script/setup
```

### Server script

The `server` script starts the Rails server on port `3000` (using the **Puma** web server.)

```bash
./script/server
```

### Update script

Periodically, you can run the `update` script to check for new versions of dependencies and to update the database schema. If you ever get a `PendingMigrationError`, run this script to migrate your database. If you always start your server using `./script/server`, you'll never need to run this directly, because `./script/server` calls `./script/update` first.

```bash
./script/update
```

### Test script

The `test` script runs the test suite (using **RSpec** for tests and **Rubocop** for code style).

```bash
./script/test
```

### Console script

If you need to use the app’s console (in any environment), use the `console` script.

```bash
./script/console
```

If you need to use the console on a remote instance of the app, specific its environment name as the first argument.

```bash
./script/console production
```

Or

```bash
./script/console staging
```

### CI Build script

Setup environment for CI and run tests. This is primarily designed to run on the continuous integration server.

```bash
./script/cibuild
```


## Deploy to Heroku

If you want to run your own copy of the Ethio API, you can!
(This requires you having a Heroku account already.)
Click this button to easily deploy to Heroku.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)


## Authors

* Shane Becker / [@veganstraightedge](https://github.com/veganstraightedge)
* ( add yourself )


## Contributing

See [CONTRIBUTING.md](https://github.com/sandstormco/ethio-api/blob/master/CONTRIBUTING.md).

If you find bugs, have feature requests or questions, please [file an issue](https://github.com/sandstormco/ethio-api/issues).


## Code of Conduct

Everyone interacting in the Ethio's project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the
[Ethio development code of conduct](https://github.com/sandstormco/ethio-api/blob/master/CODE_OF_CONDUCT.md).


## License

**PUBLIC DOMAIN**

Your heart is as free as the air you breathe.
The ground you stand on is liberated territory.

In legal text, Ethio API is dedicated to the public domain
using Creative Commons — CC0 1.0 Universal.

[http://creativecommons.org/publicdomain/zero/1.0](http://creativecommons.org/publicdomain/zero/1.0 "Creative Commons — CC0 1.0 Universal")


## Development / Deploy Workflow

To work on an issue or story card, follow these steps (roughly speaking):

- `git checkout master && git pull` to update your local files to the latest versions.

- `git checkout -B FEATURE_BRANCH_NAME` to create a feature/topic branch off of `master` to work on (use your actual feature’s for the branch name, not literally `FEATURE_BRANCH_NAME`). It's helpful if the issue ID is in the branch name, eg `137_add_xyz`.

- Do your feature development work here to fulfill the criteria of the Issue that you’re working on. I.e., write the code that you need. Test. Repeat.

- `git add . && git commit -m "Add feature XYZ [#n]"` to attach your commit to your Issue by referencing its Issue id number in your commit message. (E.g., `git commit -am "Add privacy policy to footer [#137]"`)

- `git push -u origin FEATURE_BRANCH_NAME` to push to your feature branch frequently as you work. (After your first `git push -u …`, you only need to `git push` while on that branch.)

- Go to GitHub and click the buttons to create a pull request when you’re done with the issue.

- Request a Pull Request code review by someone on the team.

- They’ll do the review asynchronously on GitHub.

- If the reviewer approves your pull request, then someone with commit access to `master` will merge the pull request into `master`.

- If the reviewer requests changes on your Pull Request, discuss and/or make those changes, update your pull request, then request another review. Repeat until the pull request is accepted.

- When the pull request is merged into `master` and the feature branch should be deleted remotely and locally.

- All commits to `master` are auto-deployed to the `staging` server: https://staging.api.ethio.app.

- Changes to the `staging` server have to be manually approved by a human to be promoted to `production` from the Heroku website. https://api.ethio.app
