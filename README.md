# fantasy-unicorn-ruby

Forex-simulation-like online trading game
[![Actions Status](https://github.com/Cherry-Squad/fantasy-unicorn-ruby/workflows/specs/badge.svg)](https://github.com/Cherry-Squad/fantasy-unicorn-ruby/actions)

## Getting started

1. Install these components:
    - Ruby >= 3.0.2
    - PostgreSQL >= 14. On Debian, install libpq-dev too.
    - Ruby on Rails >= 6.1.4
2. Clone an app and open a terminal in app's folder.
3. Run following commands:
    ```shell
    $ bundle install
    $ rake db:setup
    $ rake db:migrate
    $ rake db:seed
    ```
   Then run `rails server` to start a server on 127.0.0.1:3000.