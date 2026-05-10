# rbrun_ui

ViewComponent-based UI kit extracted from [rbrun](https://github.com/notiplus/rbrun).
Ships ~25 components (button, dialog, drawer, popover, select, table, …) backed
by Tailwind v4 design tokens, a Stimulus sidecar loader, and Floating UI for
positioning.

## Requirements

This is a Rails Engine and assumes the host app is using:

- Rails 8.1+
- Propshaft
- importmap-rails
- stimulus-rails
- tailwindcss-rails (Tailwind v4)
- IBM Plex Sans / IBM Plex Mono (loaded via the host layout)

## Installation

Add to your host app's `Gemfile`:

```ruby
gem "rbrun_ui", path: "../rbrun_ui"   # or git: / version pin
```

Then run the install generator:

```sh
bin/rails g rbrun_ui:install
```

The generator wires three things into the host:

1. `app/assets/tailwind/application.css` — adds an `@source` directive
   pointing at the gem's component dir (so Tailwind v4 picks up the
   utility classes the components emit) and `@import "rbrun_ui";` for
   the design tokens.
2. `app/javascript/controllers/index.js` — registers the sidecar
   loader so component-local `controller.js` files become Stimulus
   controllers under the `ui-<name>` identifier.
3. Importmap pins are merged in automatically by the engine — no host
   `config/importmap.rb` edit needed.

## Usage

```erb
<%= component("button", label: "Save") %>
<%= component("button", label: "Save", variant: :secondary, size: :sm) %>
<%= component("badge", label: "New", tone: :amber) %>

<%= render RbrunUi::Ui::Dialog::Component.new(trigger_label: "Open") do |dialog| %>
  <% dialog.with_header do |header| %>
    <% header.with_left { "Settings" } %>
  <% end %>
  Body content goes here.
<% end %>
```

The `component("name", …)` helper resolves to `RbrunUi::Ui::<Name>::Component`.

## Components

area, area_footer, area_header, avatar, badge, button, card, code, dialog,
drawer, filter, input, item, menu, menu_group, menu_option, pagination,
popover, popup_list, select, table, table_cell, table_header, table_row.

## License

MIT.
