require "test_helper"

class RbrunUi::Ui::Code::ComponentTest < ViewComponent::TestCase
  test "renders formatted code block" do
    render_inline(RbrunUi::Ui::Code::Component.new(code: %(component("button", label: "Save"))))

    assert_selector %(pre code.highlight.language-erb)
    assert_text %(component("button", label: "Save"))
  end

  test "tokenises ERB through Rouge — emits highlighted spans" do
    erb = %(<%= component "button", label: "Save" %>)
    render_inline(RbrunUi::Ui::Code::Component.new(code: erb, language: "erb"))

    # Rouge's `erb` lexer wraps the `<%=`/`%>` delimiters in a span
    # of class `cp` (preprocessor). Asserting that span lands proves
    # the highlighter ran end-to-end (lexer found, formatter emitted).
    assert_selector "code.highlight span.cp"
    # The Ruby string literal "Save" inside the ERB tag tokenises as
    # `s2` (double-quoted string).
    assert_selector "code.highlight span.s2"
  end

  test "falls back to PlainText for an unknown language" do
    render_inline(RbrunUi::Ui::Code::Component.new(code: "anything goes here", language: "totally-not-a-real-language"))

    # PlainText lexer emits no highlight spans, just the literal text.
    assert_selector "code.highlight.language-totally-not-a-real-language"
    assert_text "anything goes here"
  end
end
