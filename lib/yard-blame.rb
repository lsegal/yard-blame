module GitBlameHandler
  def self.blame_files; @@blame_files ||= {} end
  def register(obj) @object = obj; super end
  
  def process
    super
    info, bline = {}, statement.line_range.begin
    unless content = GitBlameHandler.blame_files[parser.file]
      GitBlameHandler.blame_files[parser.file] = content =
        `git blame -l #{parser.file}`.split("\n")
    end
    bline.upto(statement.line_range.end) do |index|
      line = content[index-1]
      if line =~ /^\^?(\S+)\s+\((.+?)\s+\d+/
        info[index] = {:rev => $1, :name => $2}
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
        link_url("http://github.com/#{ENV['YARD_USER']}/#{ENV['YARD_PROJECT']}/blame/#{info[:rev]}/#{obj.file}#L#{l}", sprintf("%.8s", info[:rev])) + 
          " " + h(info[:name])
      else
        ""
      end
    end.join("\n")
  end
end

YARD::Templates::Engine.register_template_path(File.dirname(__FILE__) + '/../templates')
YARD::Templates::Helpers::MethodHelper.send(:include, GitBlameHelper)
YARD::Handlers::Ruby::MethodHandler.send(:include, GitBlameHandler)
YARD::Handlers::Ruby::Legacy::MethodHandler.send(:include, GitBlameHandler)
