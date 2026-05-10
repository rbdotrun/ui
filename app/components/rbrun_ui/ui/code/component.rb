require "rouge"

class RbrunUi::Ui::Code::Component < RbrunUi::ApplicationViewComponent
  option(:code)
  option(:language,   default: proc { "erb" })
  option(:class_name, optional: true)

  def root_classes
    TailwindMerge::Merger.new.merge([
      "rounded-lg border border-stone-200 bg-white px-4 py-3 font-mono text-[13px] leading-6 text-stone-800",
      class_name
    ].compact.join(" "))
  end

  # Highlighted, HTML-safe markup. Rouge tokenises the source and emits
  # `<span class="…">` tags scoped to the standard Pygments class names
  # (.k, .s, .nb, etc.) — themed by `app/assets/stylesheets/code-themes/github-light.css`.
  # Falls back to escaped plain text if the language is unknown.
  def highlighted_code
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexer.find(language.to_s) || Rouge::Lexers::PlainText.new
    formatter.format(lexer.lex(code)).html_safe
  end

  erb_template <<~ERB
    <div class="<%= root_classes %>">
      <pre class="overflow-x-auto whitespace-pre-wrap"><code class="highlight language-<%= language %>"><%= highlighted_code %></code></pre>
    </div>
  ERB
end
