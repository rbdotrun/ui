# RbrunUi::Ui::Popover::Component — generic anchored floater.
#
# Renders a trigger element + a content panel that opens in the browser's
# top layer (native HTML `popover` attribute). Positioning is computed by
# Floating UI on every open/scroll/resize, so the content panel always
# tracks the trigger and flips/shifts to stay on screen.
#
# Two slots:
#   - `with_trigger` → the clickable element (any markup; usually a button)
#   - `with_body`    → the panel that appears
#
# (`with_body`, not `with_content`, because `:content` is reserved by
# ViewComponent for the unspecified block-yielded content of a component.)
#
# Examples:
#   <%= ui("popover") do |p| %>
#     <% p.with_trigger { ui("button", label: "Help", icon: "help-circle") } %>
#     <% p.with_body do %>
#       <p class="text-sm">A short hint.</p>
#     <% end %>
#   <% end %>
#
#   <%= ui("popover", placement: :bottom_end, offset: 8) do |p| %>
#     ...
#   <% end %>
#
# Options:
#   placement: :top, :top_start, :top_end,
#              :bottom, :bottom_start, :bottom_end,
#              :left, :left_start, :left_end,
#              :right, :right_start, :right_end
#   offset:    pixel gap between trigger and content (default 4)
#
# Behavior is controller-owned visibility + Floating UI positioning,
# wired in `controller.js` next to this file. The controller handles
# toggle, outside-click dismiss, Esc-to-close, and focus return.
class RbrunUi::Ui::Popover::Component < RbrunUi::ApplicationViewComponent
  PLACEMENTS = %i[
    top top_start top_end
    bottom bottom_start bottom_end
    left left_start left_end
    right right_start right_end
  ].freeze

  option(:placement, default: proc { :bottom_start })
  option(:offset,    default: proc { 4 })

  renders_one :trigger
  renders_one :body

  style do
    base do
      # Popover content panel base.
      #
      # The user-agent stylesheet centers a [popover]:popover-open with
      # `inset: 0; margin: auto`. Floating UI sets explicit top/left
      # inline, but for the FIRST paint (the moment the popover opens,
      # before our `toggle` event handler runs), we need the element to
      # be at a known visible position — otherwise it renders at an
      # undefined location (varies by browser, often the wrong spot or
      # offscreen) and the user reports "nothing opens".
      #
      # `top-0 left-0` gives a definite top-left anchor; `m-0` overrides
      # the user-agent margin-auto centering. Floating UI's
      # `Object.assign(style, { top, left })` then snaps the popover to
      # the anchored position on the same frame.
      #
      # `w-max` is Floating UI's required `width: max-content` — without
      # it, the floating element gets squished by its parent's width
      # constraints (https://floating-ui.com/docs/computePosition#initial-layout).
      %w[
        top-0 left-0 m-0 w-max fixed z-50
        bg-white text-stone-900
        border border-border rounded-md shadow-lg
        focus:outline-none
      ]
    end
  end

  # Stable id for the popover element. Two popovers can coexist on the
  # same page because each gets its own id.
  def popover_id
    @popover_id ||= "popover-#{SecureRandom.alphanumeric(8)}"
  end

  # Floating UI takes hyphenated placements ("bottom-start"). Our Ruby
  # symbols are snake_case for consistency with the rest of the API.
  def floating_ui_placement
    placement.to_s.tr("_", "-")
  end

  erb_template <<~ERB
    <div data-controller="<%= controller_name %>"
         data-action="<%= controller_name %>:close-><%= controller_name %>#close"
         data-<%= controller_name %>-placement-value="<%= floating_ui_placement %>"
         data-<%= controller_name %>-offset-value="<%= offset %>">
      <div data-<%= controller_name %>-target="trigger"
           data-action="click-><%= controller_name %>#toggle"
           class="inline-block">
        <%= trigger %>
      </div>
      <div data-<%= controller_name %>-target="content"
           id="<%= popover_id %>"
           hidden
           aria-hidden="true"
           class="<%= style %>">
        <%= body %>
      </div>
    </div>
  ERB
end
