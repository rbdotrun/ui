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
engine's showcase), the host needs **two more wires**: the engine's
Tailwind utilities pulled into your CSS bundle, and the engine's Stimulus
controllers registered against the host's Stimulus application.

**a. Pull engine Tailwind utilities into your host bundle** via the official
`tailwindcss-rails` (>= 4.4) Rails Engines support. The gem ships its
Tailwind input at `app/assets/tailwind/rbrun_ui/engine.css`; the host opts
in with one `@import` line in its own tailwind input:

```css
/* app/assets/tailwind/application.css */
@import "tailwindcss";
@import "../builds/tailwind/rbrun_ui";   /* opt-in to engine utilities */

@theme {
  /* your host's tokens; these win over the engine's defaults */
}
```

On `tailwindcss:build` / `:watch`, `tailwindcss-rails` auto-discovers the
engine and writes the `app/assets/builds/tailwind/rbrun_ui.css` shim that
the `@import` above resolves to. One Tailwind watcher, one CSS bundle,
served as `tailwind` by Propshaft — link it from your layout:

```erb
<%# app/views/layouts/application.html.erb %>
<%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
```

No `@source` directives in your host CSS, no shipped precompiled bundle to
keep in sync, no per-request fork/exec to rebuild. The gem stays a pure
source distribution.

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

### Override design tokens

`engine.css` carries the gem's default tokens — stone-based palette, IBM
Plex Sans / Mono. To override, redeclare tokens in your host
`tailwind/application.css` **after** the engine `@import`:

```css
@import "tailwindcss";
@import "../builds/tailwind/rbrun_ui";

@theme {
  --color-primary:   #4338ca;  /* indigo */
  --color-secondary: #f5f3ff;
  --color-border:    #e0e7ff;
  --font-sans: "Inter", sans-serif;
}
```

Tailwind v4 rebuilds utilities from the latest `@theme` it sees, so your
declarations win: `bg-primary`, `border-border`, `font-sans`, etc. resolve
to your values everywhere — including the showcase, because there's exactly
one Tailwind compile in the system. If you want the showcase pinned to the
gem's reference look, mount the engine in a separate dummy app that has no
`@theme` of its own.

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
bundle exec rake test           # runs the dummy-app Minitest suite
```

The gem is a pure source distribution — no precompiled CSS to keep in
sync. The host running `tailwindcss:watch` picks up edits to component
templates / `style do` blocks / engine.css automatically, because the
auto-generated `app/assets/builds/tailwind/rbrun_ui.css` shim re-imports
this engine.css on every compile.

## License

MIT.
