# Agent Instructions

## Completion Criteria
Before reporting implementation as complete, run both commands and confirm they pass:
1. `bundle exec rubocop`
2. `bundle exec rspec`

If either check fails, fix the issues and run both commands again.

## CI Command
- Use `bin/ci` for a full local gate.

## Commit Message Rule
When creating commits in this repository, always use Conventional Commits.

Allowed formats:
1. `<type>: <summary>`
2. `<type>(<scope>): <summary>`

Common types:
- `feat`
- `fix`
- `docs`
- `test`
- `refactor`
- `chore`

Examples:
- `feat: add request specs for products`
- `fix(products): display kind labels in Japanese`
