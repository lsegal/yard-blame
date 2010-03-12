require 'yard'

YARD::Templates::Engine.register_template_path(File.dirname(__FILE__) + '/../templates')

class GitBlameHandler < YARD::Handlers::Ruby::MethodHandler
  handles :def, :defs
  
  @@blame_files = {}
  
  def register(obj); @object = obj; super end
  
  # @return [String] the revse of the string
  def process
    super
    info = {}
    begin_line, end_line = statement.line_range.begin, statement.line_range.end
    lines = `git blame -L #{begin_line},#{end_line} #{statement.file}`.split(/\r\n/)
    lines.each.with_index do |line, index|
      if line =~ /^\^?(\S+)\s+\((.+?)\s+\d/
        info[statement.line_range.begin + index] = {rev: $1, name: $2}
      end
    end
    @object[:blame_info] = info
  end
end