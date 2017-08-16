# Contributing to the OpenDaylight Puppet Module

We work to make contributing easy. Please let us know if you spot something
we can do better.

#### Table of Contents

1. [Overview](#overview)
2. [Communication](#communication)
   - [Trello](#trello)
   - [Email](#email)
   - [IRC](#irc)
3. [Patches](#patches)
4. [Testing](#testing)
   - [Test Dependencies](#test-dependencies)
   - [Coala Linting](#coala-linting)
   - [Syntax and Style Tests](#syntax-and-style-tests)
   - [Unit Tests](#unit-tests)
   - [System Tests](#system-tests)
   - [Tests in Continuous Integration](#tests-in-continuous-integration)

## Overview

This is an offical upstream OpenDaylight codebase under the
[Integration/Packaging project][1].

We use [Trello][2] to track TODOs and [Gerrit][3] to submit changes. Email
the [integration-dev mailing list][4] to get in touch.

## Communication

### Trello

Enhancements, bugs and such are tracked on [Trello][2]. The Trello board is
shared with other Integration projects and related efforts. Puppet-opendaylight
is under the scope of the Integration/Packaging project, which has a column
and [tag][5] to collect its cards. Cards related to puppet-opendaylight will
typically mention it by name in the title.

### Email

Please use the [integration-dev][4] mailing list to contact puppet-opendaylight
developers. Please don't reach out to developers directly, per open source best
practices.

### IRC

To chat synchronously with developers, join the **#opendaylight-integration**
on `chat.freenode.net`. If you're not familar with IRC, there are [web
clients][6] that can make getting started easy.

## Patches

Please use [Gerrit][3] to submit patches. See the [ODL Gerrit docs][7]
general getting-started help.

Other tips for submitting excellent patches:

- Please provide test coverage for your changes.
- If applicable, please provide documentation updates to reflect your changes.

## Testing

### Test Dependencies

A Vagrant environment is provided to help manage test dependencies. All
software prerequisites and configuration for running all types of tests
should be handled automatically.

To provision and connect to a Fedora-based VM with test tools installed:

```
$ vagrant up fedora
$ vagrant ssh fedora
# cd to ~/puppet-opendaylight and hack away
```

A CentOS-based VM is also provided.

### Coala Linting

We use Coala (manged by tox) to run various linters, like spacing, line
length, Markdown, YAML, JSON, etc.

```
$ tox
```

### Syntax and Style Tests

We use [Puppet Lint][8], [Puppet Syntax][9] and [metadata-json-lint][10] to
validate the module's syntax and style.

```
$ bundle exec rake lint
$ bundle exec rake syntax
$ bundle exec rake metadata_lint
```

### Unit Tests

We use rspec-puppet to provide unit test coverage.

To run the unit tests and generate a coverage report, use:

```
$ bundle exec rake spec
```

To run the syntax, style and unit tests in one rake task (recommended), use:

```
$ bundle exec rake test
```

### System Tests

While the [unit tests](#unit-tests) are able to quickly find many errors,
they don't do much more than checking that the code compiles to a given state.
To verify that the Puppet module behaves as desired once applied to a real,
running system, we use [Beaker][11].

Beaker stands up virtual machines or containers using Vagrant or Docker,
applies the OpenDaylight Puppet module with various combinations of params
and uses [Serverspec][12] to validate the resulting system state.

To run Beaker tests against CentOS 7 in a VM using the latest OpenDaylight
Carbon RPM, use:

```
$ bundle exec rake cent_6test_vm
```

To do the same tests in a CentOS container:

```
$ bundle exec rake cent_6test_dock
```

To run VM or container-based tests for all OSs:

```
$ bundle exec rake acceptance_vm
$ bundle exec rake acceptance_dock
```

If you'd like to preserve the Beaker VM after a test run, perhaps for manual
inspection or a quicker follow-up test run, use the `BEAKER_destroy`
environment variable.

```
$ BEAKER_destroy=no bundle exec rake cent_6test_vm
```

You can then connect to the VM by navigating to the directory that contains
its Vagrantfile and using standard Vagrant commands.

```
$ cd .vagrant/beaker_vagrant_files/centos-7.yml/
$ vagrant status
Current machine states:

centos-7                  running (virtualbox)
$ vagrant ssh
$ sudo systemctl is-active opendaylight
active
$ logout
$ vagrant destroy -f
```

### Tests in Continuous Integration

The OpenDaylight Puppet module uses OpenDaylight's Jenkins silo to run tests
in CI. Some tests are triggered when changes are proposed, others are triggered
periodically to validate things haven't broken underneath us. See the
[`puppet-*` tests][13] on the Jenkins web UI for a list of all tests.

[1]: https://wiki.opendaylight.org/view/Integration/Packaging "Integration/Packaging project wiki"

[2]: https://trello.com/b/ACYMpTVD/opendaylight-integration "Integration Tello board"

[3]: https://git.opendaylight.org/gerrit/#/q/project:integration/packaging/puppet-opendaylight "puppet-opendaylight Gerrit"

[4]: https://lists.opendaylight.org/mailman/listinfo/integration-dev "integration-dev mailing list"

[5]: https://trello.com/b/ACYMpTVD/opendaylight-integration?menu=filter&filter=label:Int%2FPack "Integration/Packaging Trello cards"

[6]: http://webchat.freenode.net/?channels=opendaylight-integration "opendaylight-integration IRC web client"

[7]: http://docs.opendaylight.org/en/latest/gerrit.html "OpenDaylight Gerrit docs"

[8]: http://puppet-lint.com/ "Puppet lint"

[9]: https://github.com/gds-operations/puppet-syntax "Puppet syntax"

[10]: https://github.com/puppet-community/metadata-json-lint "Metadata JSON lint"

[11]: https://github.com/puppetlabs/beaker "Beaker system tests"

[12]: http://serverspec.org/resource_types.html "Serverspec"

[13]: https://jenkins.opendaylight.org/releng/view/packaging/search/?q=puppet "Puppet CI jobs"
