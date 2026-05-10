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

There are two scopes the gem supports:

1. **Engine-mounted pages only** (you only want the showcase, or you'll
   render components inside engine routes). **Two lines** — gem + mount.
2. **Components on host pages too** (you want `ui("dialog")`,
   `ui("popover")`, etc. on your own routes). **Two more lines** — load
   the engine's precompiled CSS and register the engine's Stimulus
   controllers against the host's Stimulus app.

### 1 — Minimum (engine-mounted pages only)

```ruby
# Gemfile
gem "rbrun_ui", git: "https://github.com/rbdotrun/ui.git"
```

```ruby
# config/routes.rb
mount RbrunUi::Engine => "/_dev/rbrun_ui" if Rails.env.local?
```

After `bundle install`, hit `/_dev/rbrun_ui/showcase` — every component in
every variant, rendered with the gem's own layout, own Stimulus app, own
precompiled Tailwind bundle.

The engine's `lib/rbrun_ui/engine.rb` automatically:

- Adds `app/javascript` and `app/components` to `config.assets.paths` so
  Propshaft can serve sidecar `controller.js` files.
- Auto-includes `RbrunUi::ApplicationHelper` into every host controller, so
  the `ui(...)` helper is available in any view (engine or host).
- Maintains a parallel `RbrunUi.importmap` for engine pages (isolated from
  the host's `Rails.application.importmap` so version conflicts can't
  happen) **AND** appends the engine's `config/importmap.rb` to the host's
  `app.config.importmap.paths`, so the engine's pins
  (`rbrun_ui/controllers/loader`, the per-component sidecars, the
  `@floating-ui/*` CDN pins) are resolvable from host pages too.

### 2 — Components on host pages

If you want to render `ui(...)` components on your own routes (not just the
engine's showcase), the host needs **two more wires**: the gem's
precompiled Tailwind bundle in your layout, and the gem's Stimulus
controllers registered against the host's Stimulus application.

**a. Load the gem's precompiled CSS in your host layout** so utility classes
the components emit (`fixed inset-0 z-50` for dialog, `data-[state=open]:…`
arbitrary variants, etc.) are available without your host Tailwind compile
having to scan the gem's templates:

```erb
<%# app/views/layouts/application.html.erb %>
<%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "rbrun_ui/tailwind", "data-turbo-track": "reload" %>
```

The gem ships its own pre-built `app/assets/stylesheets/rbrun_ui/tailwind.css`
so you do **not** need to add `@source` directives to your own
`tailwind/application.css` and you do **not** need to know where the gem
lives in `bundler/gems/`. Bundle update the gem and the precompiled bundle
follows automatically.

**b. Register the engine's Stimulus controllers against the host's Stimulus
application** so `data-controller="rbrun-ui--dialog"` etc. actually wakes up
on host pages:

```js
// app/javascript/controllers/index.js
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import { eagerLoadEngineControllersFrom } from "rbrun_ui/controllers/loader"

eagerLoadControllersFrom("controllers", application)
eagerLoadEngineControllersFrom("rbrun_ui/components/ui", application)
```

The `under: "rbrun_ui/components/ui"` argument is what makes the loader
derive identifiers like `rbrun-ui--dialog` (matching what the components
emit via their `controller_name` method). No further importmap edits — the
engine already merged its pins into the host's importmap (see step 1).

**That's it.** Restart Rails so the engine initializer re-runs and the
host's importmap picks up the gem pins. Click any `ui("dialog", ...)`
trigger on a host page; it opens.

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

### Override design tokens (host pages)

Loading `rbrun_ui/tailwind` (step 2a above) gives the host the gem's
default tokens — stone-based palette, IBM Plex Sans / Mono, etc. To
override on **host** pages, redeclare tokens in your host
`tailwind/application.css`:

```css
@import "tailwindcss";

@theme {
  --color-primary:   #4338ca;  /* indigo */
  --color-secondary: #f5f3ff;
  --color-border:    #e0e7ff;
  --font-sans: "Inter", sans-serif;
}
```

Because your host bundle is loaded **after** `rbrun_ui/tailwind` in the
layout (it's the last `stylesheet_link_tag`), your `@theme` redeclarations
win cascade order: `bg-primary`, `border-border`, `font-sans`, etc. now
resolve to your values on host pages. Engine-mounted pages still render
with the gem's defaults — that isolation is by design (the showcase shows
the reference look).

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
