module GitBlameHandler
  def self.blame_files; @@blame_files ||= {} end
  def register(obj) @object = obj; super end

  def process
    super
    info, bline, eline = {}, statement.line_range.begin, statement.line_range.end

    if GitBlameHandler.blame_files[parser.file]
      set_blame_info(bline, eline)
      return
    end

    content = `git blame -p -l #{parser.file}`
    authors_cache = {}
    content.scan(/^([0-9a-f]{40}) (\d+) (\d+) (\d+)$(?:\nauthor (.+))?$/).each do |match|
      rev        = match[0]
      start_line = match[2].to_i
      num_lines  = match[3].to_i
      author     = match[4]

      if author
        authors_cache[rev] = author
      else
        author = authors_cache[rev]
      end

      num_lines.times do |i|
        info[start_line + i] = {:rev => rev, :name => author}
      end
    end

    GitBlameHandler.blame_files[parser.file] = info
    set_blame_info(bline, eline)
  end

  private
  def set_blame_info(bline, eline)
    all_revs = GitBlameHandler.blame_files[parser.file]
    revs = all_revs.reject {|key, value| !(bline..eline).include?(key)} #reject to work with ruby 1.8
    @object[:blame_info] = revs
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
