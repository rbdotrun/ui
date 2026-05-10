# RbrunUi::Ui::Avatar::Component — circular avatar with image or initials fallback.
#
# Examples:
#   component("avatar", name: "Alice Johnson")
#   component("avatar", name: "Alice Johnson", src: "/alice.jpg", size: :lg)
#
# Sizes: :sm, :md, :lg, :xl
class RbrunUi::Ui::Avatar::Component < RbrunUi::ApplicationViewComponent
  option(:name,     optional: true)
  option(:src,      optional: true)
  option(:alt,      optional: true)
  option(:initials, optional: true)
  option(:icon,     optional: true)
  option(:size,     default: proc { :md })

  SIZE_CLASSES = {
    sm: %w[h-8 w-8 text-xs],
    md: %w[h-10 w-10 text-sm],
    lg: %w[h-12 w-12 text-base],
    xl: %w[h-16 w-16 text-lg]
  }.freeze

  style do
    base do
      %w[
        inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full
        bg-secondary text-stone-700 select-none
      ]
    end

    variants do
      size do
        sm { SIZE_CLASSES[:sm] }
        md { SIZE_CLASSES[:md] }
        lg { SIZE_CLASSES[:lg] }
        xl { SIZE_CLASSES[:xl] }
      end
    end
  end

  def accessible_name
    alt.presence || name.presence || computed_initials
  end

  def icon?
    icon.present?
  end

  def computed_initials
    return initials.to_s.strip.upcase if initials.present?
    return "?" if name.blank?

    parts = name.to_s.strip.split(/\s+/).reject(&:blank?)
    return "?" if parts.empty?

    parts.first(2).map { |part| part[0] }.join.upcase
  end

  def icon_class
    case size
    when :sm then "h-4 w-4"
    when :md then "h-5 w-5"
    when :lg then "h-6 w-6"
    else "h-7 w-7"
    end
  end

  erb_template <<~ERB
    <span class="<%= style(size:) %>" aria-label="<%= accessible_name %>">
      <% if src.present? %>
        <%= image_tag src,
                      alt: accessible_name,
                      class: "block h-full w-full rounded-full object-cover" %>
      <% elsif icon? %>
        <%= lucide_icon(icon, class: [icon_class, "text-stone-500"].join(" ")) %>
      <% else %>
        <span aria-hidden="true" class="font-medium"><%= computed_initials %></span>
      <% end %>
    </span>
  ERB
end
