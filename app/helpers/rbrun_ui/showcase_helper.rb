module RbrunUi
  module ShowcaseHelper
    # ERB tag opener — control-flow keywords that need a matching `end`.
    ERB_KEYWORD_OPENER = /<%[-=]?\s*(?:if|unless|case|while|until|for|begin)\b/
    # ERB tag opener — any `do %>` (with or without block args, with or
    # without ERB trim mode `-%>`).
    ERB_DO_OPENER      = /\bdo\s*(?:\|[^|]*\|)?\s*-?%>/
    # ERB tag closer — `<% end %>` with optional ERB trim mode.
    ERB_END_CLOSER     = /<%-?\s*end\s*-?%>/

    # Returns the literal ERB source of the block passed to
    # `render "rbrun_ui/dev/showcase/swatch", … do …`. Walks
    # `caller_locations` to find the calling .erb file, reads it from
    # disk, locates the `do %>` opener and its matching `<% end %>`,
    # and returns the dedented block body.
    #
    # Used by app/views/rbrun_ui/dev/showcase/_swatch.html.erb so the
    # showcase can render the live demo and its source side by side
    # without authors having to maintain a duplicate string copy of
    # every block.
    def swatch_source_for_caller
      location = caller_locations.find do |loc|
        next false unless loc.path.end_with?(".html.erb")
        next false if loc.path.end_with?("dev/showcase/_swatch.html.erb")

        true
      end
      return nil unless location

      extract_erb_block(File.read(location.path), location.lineno)
    rescue Errno::ENOENT, ArgumentError
      nil
    end

    private

      # Given the source of an ERB file and the line number of the `render`
      # call, finds the matching `do %>` ... `<% end %>` block and returns
      # its dedented body. Returns nil if no matching block is found.
      #
      # Regex-based opener/closer counter — would be fooled by a string
      # literal containing `<% end %>`, which never occurs in the showcase
      # partials. Swap to a parser if that assumption breaks.
      def extract_erb_block(source, render_lineno)
        lines = source.lines

        # The render call may span multiple lines (trailing keyword args).
        # Walk forward from the render line until we hit a line ending in
        # `do %>` — that is the actual block opener.
        cursor = render_lineno - 1
        cursor += 1 while cursor < lines.length && lines[cursor] !~ /\bdo\s*(?:\|[^|]*\|)?\s*-?%>\s*\z/
        return nil if cursor >= lines.length

        block_start = cursor + 1
        depth = 1
        cursor = block_start
        while cursor < lines.length
          line = lines[cursor]
          depth += count_erb_openers(line)
          depth -= count_erb_closers(line)
          return dedent_lines(lines[block_start...cursor].join) if depth.zero?

          cursor += 1
        end
        nil
      end

      def count_erb_openers(line)
        line.scan(ERB_KEYWORD_OPENER).length + line.scan(ERB_DO_OPENER).length
      end

      def count_erb_closers(line)
        line.scan(ERB_END_CLOSER).length
      end

      # Strip the common leading-whitespace prefix from every line. Blank
      # lines (whitespace-only) are passed through untouched.
      def dedent_lines(text)
        return text if text.empty?

        indents = text.lines.reject { |l| l.strip.empty? }.map { |l| l[/\A */].length }
        return text if indents.empty?

        n = indents.min
        return text if n.zero?

        text.lines.map { |l| l.strip.empty? ? l : l[n..] }.join
      end
  end
end
