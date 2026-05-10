class RbrunUi::Ui::Badge::Component < RbrunUi::ApplicationViewComponent
  option(:label)
  option(:tone,       default: proc { :neutral })
  option(:class_name, optional: true)

  TONE_CLASSES = {
    neutral: %w[border-stone-200 bg-stone-100 text-stone-700],
    amber:   %w[border-amber-200 bg-amber-50 text-amber-700],
    sky:     %w[border-sky-200 bg-sky-50 text-sky-700],
    red:     %w[border-red-200 bg-red-50 text-red-700]
  }.freeze

  style do
    base do
      %w[
        inline-flex items-center rounded-full border px-4 py-2
        text-[11px] font-semibold uppercase tracking-[0.14em]
      ]
    end

    variants do
      tone do
        neutral { TONE_CLASSES[:neutral] }
        amber   { TONE_CLASSES[:amber] }
        sky     { TONE_CLASSES[:sky] }
        red     { TONE_CLASSES[:red] }
      end
    end
  end

  def root_classes
    TailwindMerge::Merger.new.merge([style(tone:), class_name].compact.join(" "))
  end

  erb_template <<~ERB
    <span class="<%= root_classes %>"><%= label %></span>
  ERB
end
