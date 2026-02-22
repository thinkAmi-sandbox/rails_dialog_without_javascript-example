# Product Management App (Rails)

## Prerequisites
- Ruby and Node are managed by `mise` in this project.
- Install dependencies:
  - `bundle install`

## Run the app
- `bin/rails s`

## Quality Gate (Definition of Done)
Code is considered complete only when both checks pass:
1. `bundle exec rubocop`
2. `bundle exec rspec`

If either command fails, the work is not complete.

## CI
- Run all project checks with:
  - `bin/ci`

In restricted environments where RuboCop cache cannot be written to home:
- `XDG_CACHE_HOME=tmp/.cache bundle exec rubocop`
