# rbrun_ui

A Rails Engine providing ~24 ViewComponents (button, dialog, drawer, popover,
select, table, …) backed by Tailwind v4, Stimulus, and Floating UI.

The engine is **fully isolated** from the host: it owns its own Stimulus
application, its own `Importmap::Map`, its own layout, and its own compiled
Tailwind bundle. Mounting the engine pulls a sealed component universe in;
host JS, host CSS, and host helpers are untouched.

## Requirements

The host app needs:

- Rails 8.1+
- Propshaft
- importmap-rails
- stimulus-rails
- tailwindcss-rails (Tailwind v4) — only required if you use components on
  host pages; engine pages bring their own pre-compiled CSS

## Installation

Two lines, that's the entire integration.

```ruby
# Gemfile
gem "rbrun_ui", git: "https://github.com/rbdotrun/ui.git"
```

```ruby
# config/routes.rb
mount RbrunUi::Engine => "/_dev/rbrun_ui" if Rails.env.local?
```

That's it. No install generator. No CSS edits. No JS imports. No importmap
changes. No helper includes. The engine wires itself.

After `bundle install`, hit `/_dev/rbrun_ui/showcase` to see every component
in every variant.

## Usage on host pages

Render a component anywhere via the `ui(...)` helper:

```erb
<%= ui("button", label: "Save") %>
<%= ui("button", label: "Save", variant: :secondary, size: :sm) %>
<%= ui("badge", label: "New", tone: :amber) %>

<%= ui("dialog", trigger_label: "Open settings") do |dialog| %>
  <% dialog.with_header do |header| %>
    <% header.with_left { "Workspace settings" } %>
  <% end %>
  <% dialog.with_footer do |footer| %>
    <% footer.with_right do %>
      <%= ui("button", label: "Cancel", variant: :secondary, data: ui_dialog_close) %>
      <%= ui("button", label: "Save changes") %>
    <% end %>
  <% end %>
  Body goes here.
<% end %>
```

The helpers `ui_dialog_close`, `ui_drawer_close`, `ui_popover_close` return
the right `data:` hash to dispatch a close action — typo-safe, no string
construction.

`ui("name", …)` resolves to `RbrunUi::Ui::<Name>::Component`. You can also
render directly:

```erb
<%= render RbrunUi::Ui::Button::Component.new(label: "Save") %>
```

### Tailwind on host pages

If you use components on host pages, the host's Tailwind compile needs to
scan the gem's component templates so utility classes like `bg-secondary`,
`border-border`, `font-sans` get included in the host's bundle. Add to the
host's `app/assets/tailwind/application.css`:

```css
@import "tailwindcss";
@source "../../../path/to/gem/app/components";
```

Find the path with `bundle info rbrun_ui` and use the `gem_dir` it prints.
For local development with `path:` or a checked-out clone, point at that
directory instead.

### Override design tokens

Engine pages always render with the gem's defaults (the showcase shows the
reference look). To override tokens on **host** pages, redeclare them in the
host's `@theme` block:

```css
@import "tailwindcss";
@source "...";

@theme {
  --color-primary:   #4338ca;  /* indigo */
  --color-secondary: #f5f3ff;
  --color-border:    #e0e7ff;
  --font-sans: "Inter", sans-serif;
}
```

Tailwind v4 rebuilds utility classes from the latest `@theme` declaration,
so `bg-primary`, `border-border`, `font-sans`, etc. now resolve to the host's
values on host pages. Engine pages stay on the gem defaults — that
isolation is by design.

### IBM Plex font

The engine layout loads IBM Plex Sans / IBM Plex Mono from Google Fonts.
For host pages using components, either load the same fonts in your host
layout or override `--font-sans` / `--font-mono` to your own stack.

## Components

area, area_footer, area_header, avatar, badge, button, card, code, dialog,
drawer, filter, input, item, menu, menu_group, menu_option, pagination,
popover, popup_list, select, table, table_cell, table_header, table_row.

## Stimulus identifiers

Engine controllers register under `rbrun-ui--<name>` (e.g.
`rbrun-ui--dialog`, `rbrun-ui--popover`). You shouldn't need to type these
strings — use the `ui_dialog_close` / `ui_drawer_close` / `ui_popover_close`
helpers for the common close-from-inside dispatch case. If you need
something custom, the convention is `rbrun-ui--<component>#<method>`.

## Development

```sh
bundle install
bundle exec rake test           # 24 runs, 140 assertions
bin/rake rbrun_ui:tailwind_build  # recompile engine CSS bundle
bin/rake rbrun_ui:tailwind_watch  # watch mode for component dev
```

The engine ships with a precompiled `app/assets/stylesheets/rbrun_ui/tailwind.css`
so consumers don't need to run anything to get the showcase working. Rebuild
this file (and commit it) when you change component templates or tokens.

## License

MIT.
