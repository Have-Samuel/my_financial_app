# My Financial App

Personal finance web app (Frontend Mentor-style). Rails 8.1.3, Ruby 3.4.6.

## Stack

- PostgreSQL (dev DB: `my_financail_app_development` — typo is pre-existing, keep it)
- Devise 5: two models — `User` (app account-holders, scope `:user`, helpers `current_user`/`authenticate_user!`) and `Admin` (back-office, scope `:admin`, helpers `current_admin`/`authenticate_admin!`)
- Frontend: ERB + Hotwire (Turbo + Stimulus via importmap, no Node build), Tailwind v4 standalone CLI, Font Awesome, Propshaft
- Solid Queue/Cache/Cable (DB-backed, no Redis); separate schemas in `db/{queue,cache,cable}_schema.rb`
- jbuilder for JSON

## Auth & routing rules

- All app-facing controllers must `before_action :authenticate_user!` and scope every query through `current_user` (financial data is per-user, `belongs_to :user`).
- `Admin` is back-office only and never touches domain models.
- Routes: `authenticated :user` root → `home#index` (listed first), `authenticated :admin` root → `admin#index`, fallback root → `home#index` (gated). Route constraints must use the correct scopes (`:user`, `:admin` — NOT `:admin_user`).

## Commands

- Dev server: `bin/dev` (runs Puma on :3000 + Tailwind watcher via Procfile.dev)
- DB: `bin/rails db:migrate`, `bin/rails db:test:prepare`
- Tests: `bin/rails test` (Minitest, `fixtures :all`; devise fixtures need `Devise::Encryptor.digest(Model, "password")`)
- Lint: `bin/rubocop` (rubocop-rails-omakase)
- Security: `bin/brakeman`, `bin/bundler-audit`

## Conventions

- Money as integer cents (`*_cents`), never floats.
- Thin controllers; domain logic in models/service objects.
- Fixture rows for Devise models must include a unique `email` and an `encrypted_password` digest.
