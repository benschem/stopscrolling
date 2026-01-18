# README

Ever catch yourself endlessly scrolling, wishing you were doing something more meaningful, but can’t decide what?

[stopscroll.ing](https://stopscroll.ing) helps you choose by randomly selecting an activity you like, or surpising you with something new.

## Setup

After cloning the repo, run these commands to install dependencies and setup the database:

```
bundle install
bin/rails db:setup
```

## Running it locally

Start puma

```
bin/rails server
```

## Other commands

Update ruby dependencies:

```
bundle update
```

Run specs:

```
ENV=test bundle exec rspec --format documentation --order defined
```

## Backend

- Ruby
- Rails
- Sqlite3

_Asset pipeline_

- Propshaft
- Importmap Rails

_Background jobs_

- Solid Queue (single database mode)
- TODO: Mission Control dashboard

_Email_

- TODO: SendGrid

## Front end

- ERB
- Hotwire (Turbo/Stimulus)
- [Pico CSS](https://picocss.com/)
