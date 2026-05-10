# RbrunUi::Ui::Button::Component — the standard button.
#
# Renders <button> by default; <a> when `href:` is set. Every variant /
# size / state combination is rendered at /_dev/showcase.
#
# Examples:
#   component("button", label: "Save")
#   component("button", label: "Save", variant: :secondary, size: :sm)
#   component("button", label: "Open", icon: "arrow-up-right")
#   component("button", icon: "trash-2", variant: :ghost)         # icon-only (square)
#   component("button", label: "Saving…", loading: true)
#   component("button", label: "Docs", href: "https://...")       # <a>
#
# Variants: :primary, :secondary, :ghost
# Sizes:    :sm, :md, :lg          (icon-only auto-squares to size's height)
# type:     defaults to "button" so a bare <button> in a form doesn't
#           submit accidentally. Pass type: "submit" for form actions.
#
# Loading state hides the label + icon (kept for layout) and overlays a
# spinner — handled entirely via Tailwind arbitrary variants on the
# `.btn` element + descendant classes (.btn-label, .btn-icon, .btn-spinner).
#
# Why kebab-case (vs BEM double-underscore)? Tailwind v4 treats a single
# underscore as a space inside arbitrary selectors. A doubled underscore
# in a class name (BEM-style) collapses to one space too, so a selector
# like the one we emit below would compile against a literal `<label>`
# element inside `.btn` — silently broken. Single-hyphen class names
# sidestep the rule entirely.
# (Note: do NOT write the broken pattern out as an example in any source
# file Tailwind scans — its content detector is purely textual and would
# happily emit a CSS rule from a comment.)
class RbrunUi::Ui::Button::Component < RbrunUi::ApplicationViewComponent
  option(:label,    optional: true)
  option(:icon,     optional: true)
  option(:variant,  default: proc { :primary })
  option(:size,     default: proc { :md })
  option(:disabled, default: proc { false })
  option(:loading,  default: proc { false })
  option(:href,     optional: true)
  option(:type,     default: proc { "button" })
  option(:data,     default: proc { {} })

  ICON_SIZE_CLASS = { sm: "h-3.5 w-3.5", md: "h-4 w-4", lg: "h-5 w-5" }.freeze
  SQUARE_WIDTH    = { sm: "w-7",         md: "w-8",     lg: "w-10"   }.freeze

  style do
    base do
      %w[
        btn relative inline-flex cursor-pointer items-center justify-center gap-1.5
        rounded-md font-medium select-none transition-colors ui-focus-ring
        [&[disabled]]:pointer-events-none [&[disabled]]:opacity-50
        [&.is-disabled]:pointer-events-none [&.is-disabled]:opacity-50
        [&.is-loading]:cursor-progress
        [&.is-loading_.btn-label]:invisible
        [&.is-loading_.btn-icon]:invisible
      ]
    end

    variants do
      variant do
        primary   { %w[bg-stone-900 text-white hover:bg-stone-800] }
        secondary { %w[bg-secondary text-stone-900 border border-border hover:bg-stone-200] }
        ghost     { %w[bg-transparent text-stone-700 hover:bg-secondary] }
      end

      size do
        sm { %w[h-7 px-2.5 text-xs] }
        md { %w[h-8 px-3 text-sm] }
        lg { %w[h-10 px-4 text-base] }
      end
    end
  end

  def icon_only?
    label.nil? && icon.present?
  end

  def computed_classes
    parts = [
      style(variant:, size:),
      ("#{SQUARE_WIDTH.fetch(size)} p-0 gap-0" if icon_only?),
      ("is-disabled" if disabled),
      ("is-loading"  if loading)
    ]
    TailwindMerge::Merger.new.merge(parts.compact.join(" "))
  end

  def icon_class
    "btn-icon #{ICON_SIZE_CLASS.fetch(size)}"
  end

  def spinner_class
    "btn-spinner absolute inset-0 m-auto inline-block h-4 w-4 rounded-full border-2 " \
    "border-t-current border-r-transparent border-b-transparent border-l-transparent animate-spin"
  end

  def tag_name = href ? :a : :button

  def html_attrs
    attrs = { class: computed_classes, data: }
    if href
      attrs[:href] = href
    else
      attrs[:type]     = type
      attrs[:disabled] = disabled || loading
    end
    attrs
  end

  erb_template <<~ERB
    <%= content_tag(tag_name, **html_attrs) do %>
      <%= lucide_icon(icon, class: icon_class) if icon %>
      <% if label %><span class="btn-label"><%= label %></span><% end %>
      <% if loading %><span class="<%= spinner_class %>" aria-hidden="true"></span><% end %>
    <% end %>
  ERB
end
