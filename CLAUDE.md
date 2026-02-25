# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lemon & Basil is a Ruby on Rails 7.0.4 application for a meal prep / personal chef service. It manages clients, custom menus, and meal prep orders. Ruby 3.1.2, PostgreSQL, Hotwire (Turbo + Stimulus), esbuild for JS bundling.

## Common Commands

```bash
bin/dev                          # Start dev server (Rails + JS watch via foreman)
bundle exec rspec                # Run all tests
bundle exec rspec spec/models/   # Run model specs
bundle exec rspec spec/features/ # Run feature specs
bundle exec rspec spec/models/client_spec.rb       # Run a single spec file
bundle exec rspec spec/models/client_spec.rb:15    # Run a single example by line
bin/rails db:migrate             # Run migrations
yarn build                       # Build JS (esbuild: admin.js + minimal.js)
```

No linter (rubocop/eslint) is configured.

## Architecture

### Controller Hierarchy

- **ApplicationController** — base controller with Devise sign-in/sign-out redirects
- **AdminController < ApplicationController** — enforces `authenticate_user!`, uses `admin` layout. All admin controllers inherit from this.
- **ApiController < ApplicationController** — Bearer token auth via `ENV['API_TOKEN']`, null session CSRF protection
- Public controllers (PagesController, ContactController, etc.) inherit directly from ApplicationController

### Three Layouts

- `application` — public marketing pages
- `admin` — authenticated admin panel
- `minimal` — client-facing menu submission flow

### Two JS Bundles (esbuild)

- `admin.js` — admin interface (Turbo, jQuery, Stimulus, modal logic)
- `minimal.js` — client-facing pages

### Key Models

- **User** — Devise auth; has `role` field (`admin?` checks `role == 'admin'`); owns clients, client_menus, meals
- **Client** — belongs_to :user
- **ClientMenu** — core domain model; has slug (6-char random) for public URLs; supports deep cloning via `deep_cloneable` gem for menu duplication
- **ClientMenuCategory / ClientMenuItem** — nested menu structure
- **ClientMenuSubmission / ClientMenuSelection** — client responses to menus

### Important Patterns

- **User-scoped data**: All admin queries scope through `current_user` (e.g., `current_user.clients.find(...)`) to prevent cross-user access
- **Slug-based public URLs**: ClientMenu generates random slugs for shareable `/menus/:slug` links
- **Turbo Streams**: Stimulus controllers use `@rails/request.js` for async requests returning Turbo Stream responses
- **Mailers**: Use `with(...)` params pattern; sent from `hello@lemonandbasil.co`
- **Serializers**: ActiveModelSerializers 0.10 for JSON API responses under `/api/`

### Testing

- RSpec + Capybara + Selenium (Firefox headless)
- FactoryBot with `create(...)` syntax (methods included globally)
- DatabaseCleaner: transaction strategy by default, truncation for `js: true` specs
- Feature specs use `login_as(@user, scope: :user)` via Warden test helpers
- `spec_helper.rb` hardcodes Firefox binary path to `/Applications/Firefox.app/Contents/MacOS/firefox`

### Configuration

- Time zone: `Central Time (US & Canada)`
- Environment variables via `dotenv-rails` (`.env` files)
- Module name: `Lemonbasil`
