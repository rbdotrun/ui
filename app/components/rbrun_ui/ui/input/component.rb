# RbrunUi::Ui::Input::Component — base text-like input.
#
# Keeps text input styling consistent across custom controls that need a
# search field or a standard single-line input.
class RbrunUi::Ui::Input::Component < RbrunUi::ApplicationViewComponent
  option(:type,         default: proc { "text" })
  option(:value,        default: proc { nil })
  option(:placeholder,  optional: true)
  option(:name,         optional: true)
  option(:id,           optional: true)
  option(:autocomplete, optional: true)
  option(:disabled,     default: proc { false })
  option(:class_name,   optional: true)
  option(:data,         default: proc { {} })

  style do
    base do
      %w[
        h-9 w-full rounded-md border border-border bg-white px-3
        text-sm text-stone-900 placeholder:text-stone-400
        ui-focus-ring
      ]
    end
  end

  def html_attrs
    {
      type:,
      value:,
      placeholder:,
      name:,
      id:,
      autocomplete:,
      disabled:,
      data:,
      class: TailwindMerge::Merger.new.merge([style, class_name].compact.join(" "))
    }.compact
  end

  erb_template <<~ERB
    <input <%= tag.attributes(html_attrs) %> />
  ERB
end
