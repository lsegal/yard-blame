require 'yard'

class GitBlameHandler < YARD::Handlers::Ruby::Base
  handles :def, :defs
  
  @@blame_files = {}
  
  def process
    p statement.file
  end
end