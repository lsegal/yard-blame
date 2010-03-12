require 'yard'

YARD::Templates::Engine.register_template_path(File.dirname(__FILE__) + '/../templates')

class GitBlameHandler < YARD::Handlers::Ruby::MethodHandler
  handles :def, :defs
  
  @@blame_files = {}
  
  def register(obj) @object = obj; super end
  
  # @return [String] the revse of the string
  def process
    super
    info, bline = {}, statement.line_range.begin
    unless content = @@blame_files[statement.file]
      @@blame_files[statement.file] = 
        `git blame #{statement.file}`.split("\n")
    end
    bline.upto(statement.line_range.end) do |index|
      line = @@blame_files[statement.file][index-1]
      if line =~ /^\^?(\S+)\s+\((.+?)\s+\d+/
        info[index] = {rev: $1, name: $2}
      end
    end
    @object[:blame_info] = info
  end
end

module GitBlameHelper
  def format_blame(obj)
    format_lines(obj).split("\n").map do |l| 
      next unless obj[:blame_info]
      if info = obj[:blame_info][l.to_i]
        link_url("http://github.com/#{ENV['yard_user']}/#{ENV['yard_project']}/commit/#{info[:rev]}", sprintf("% 8s", info[:rev])) + 
          " " + h(info[:name])
      else
        ""
      end
    end.join("\n")
  end
end

module YARD::Templates::Helpers::MethodHelper
  include GitBlameHelper
end