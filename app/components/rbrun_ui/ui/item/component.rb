# RbrunUi::Ui::Item::Component — two-line list row with optional leading affordance.
#
# Supports:
#   - title only
#   - title + subtitle
#   - optional custom leading content from parent
#   - optional leading icon
#   - optional leading avatar
#
# Sizes coordinate text scale, icon size, avatar size, and internal gap.
class RbrunUi::Ui::Item::Component < RbrunUi::ApplicationViewComponent
  option(:title)
  option(:subtitle, optional: true)
  option(:size,     default: proc { :md })
  option(:icon,     optional: true)
  option(:avatar,   optional: true)
  option(:title_emphasis, default: proc { :auto })

  renders_one :leading

  SIZE_CONFIG = {
    sm: {
      root: %w[gap-3],
      title: %w[text-sm],
      subtitle: %w[text-xs],
      avatar: :sm,
      icon: %w[h-4 w-4]
    },
    md: {
      root: %w[gap-4],
      title: %w[text-sm],
      subtitle: %w[text-xs],
      avatar: :md,
      icon: %w[h-4 w-4]
    },
    lg: {
      root: %w[gap-4],
      title: %w[text-base],
      subtitle: %w[text-sm],
      avatar: :lg,
      icon: %w[h-5 w-5]
    }
  }.freeze

  style do
    base do
      %w[
        flex w-full items-center rounded-md text-left
        text-stone-900
      ]
    end

    variants do
      size do
        sm { SIZE_CONFIG[:sm][:root] }
        md { SIZE_CONFIG[:md][:root] }
        lg { SIZE_CONFIG[:lg][:root] }
      end
    end
  end

  def subtitle?
    subtitle.present?
  end

  def avatar?
    avatar.present?
  end

  def icon?
    icon.present?
  end

  def avatar_name
    avatar_value(:name)
  end

  def avatar_src
    avatar_value(:src)
  end

  def avatar_initials
    avatar_value(:initials)
  end

  def avatar_icon
    avatar_value(:icon)
  end

  def avatar_size
    size_config[:avatar]
  end

  def title_classes
    ["truncate leading-5 text-stone-900", title_weight_class, *size_config[:title]].join(" ")
  end

  def subtitle_classes
    ["truncate leading-5 text-stone-500", *size_config[:subtitle]].join(" ")
  end

  erb_template <<~ERB
    <div class="<%= style(size:) %>">
      <% if avatar? %>
        <%= render RbrunUi::Ui::Avatar::Component.new(
              name: avatar_name,
              src: avatar_src,
              initials: avatar_initials,
              icon: avatar_icon,
              size: avatar_size
            ) %>
      <% elsif leading? %>
        <%= leading %>
      <% elsif icon? %>
        <%= render RbrunUi::Ui::Avatar::Component.new(
              name: title,
              icon: icon,
              size: avatar_size
            ) %>
      <% end %>

      <div class="min-w-0 flex-1">
        <div class="<%= title_classes %>"><%= title %></div>
        <% if subtitle? %>
          <div class="<%= subtitle_classes %>"><%= subtitle %></div>
        <% end %>
      </div>
    </div>
  ERB

  private

    def avatar_value(key)
      avatar&.dig(key) || avatar&.dig(key.to_s)
    end

    def size_config
      SIZE_CONFIG.fetch(size)
    end

    def title_weight_class
      case title_emphasis
      when :strong
        "font-semibold"
      when :soft
        "font-medium"
      else
        "font-normal"
      end
    end
end
