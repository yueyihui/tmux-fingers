#!/usr/bin/env ruby

# env -S is not portable? --disable-gems improves performance

class Hinter
  def initialize
    @hints_by_text = {}
  end

  def run
    lines[0..-2].each { |line| process_line(line, "\n") }
    process_line(lines[-1], "")

    STDOUT.flush
    write_hint_lookup!
  end

  private

  attr_accessor :hints, :hints_by_text

  def process_line(line, ending)
    print line.gsub(pattern) { |m| replace(m) } + ending
  end

  def write_hint_lookup!
    fd = File.open(3)

    hints_by_text.each do |text, hint|
      fd.write("#{hint}:#{text}\n")
    end

    fd.close()
  end

  def pattern
    @pattern ||= begin
      fingers_patterns = ENV['FINGERS_PATTERNS']
      Regexp.new("(#{fingers_patterns})")
    end
  end

  def hints
    return @hints if @hints

    # TODO error handling o ke ase
    hints_path = File.join(ENV["FINGERS_ALPHABET_DIR"], n_matches.to_s)
    @hints = File.open(hints_path).read.split(" ").reverse
  end

  def replace(match)
    text = match

    return text if hints.empty?

    if hints_by_text.has_key?(text)
      hint = hints_by_text[text]
    else
      hint = hints.pop
      hints_by_text[text] = hint
    end

    output_hint = hint_format % hint
    output_text = highlight_format % text[hint.length..-1]

    return output_hint + output_text
  end

  def lines
    @lines ||= STDIN.read.split("\n")
  end

  def highlight_format
    ENV['FINGERS_HIGHLIGHT_FORMAT']
  end

  def hint_format
    ENV['FINGERS_HINT_FORMAT']
  end

  def n_matches
    return @n_matches if @n_matches

    count = 0

    lines.each { |line| count = count + line.scan(pattern).length }

    @n_matches = count
  end
end


Hinter.new.run
