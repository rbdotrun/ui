class RbrunUi::Ui::Badge::Component < RbrunUi::ApplicationViewComponent
  option(:label)
  option(:tone,       default: proc { :neutral })
  option(:class_name, optional: true)

  TONE_SUITES = {
    neutral: :stone,
    amber: :amber,
    sky: :sky,
    emerald: :emerald,
    red: :rose
  }.freeze

  TONE_CLASSES = TONE_SUITES.transform_values do |suite_name|
    suite = SEMANTIC_COLOR_SUITES.fetch(suite_name)
    [suite[:border], suite[:bg_soft], suite[:text]]
  end.freeze

  style do
    base do
      %w[
        inline-flex items-center whitespace-nowrap rounded-md border
        px-1.5 py-0.5 font-mono text-[11px]/4 font-medium uppercase tracking-[0.025em] forced-colors:outline
      ]
    end

    variants do
      tone do
        neutral { TONE_CLASSES[:neutral] }
        amber   { TONE_CLASSES[:amber] }
        sky     { TONE_CLASSES[:sky] }
        emerald { TONE_CLASSES[:emerald] }
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
