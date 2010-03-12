SPEC = Gem::Specification.new do |s|
  s.name          = "yard-blame"
  s.summary       = "Adds git blame info to your method source views." 
  s.version       = '1.0.0'
  s.date          = "2010-03-12"
  s.author        = "Loren Segal"
  s.email         = "lsegal@soen.ca"
  s.homepage      = "http://yardoc.org"
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir.glob("{docs,bin,lib,spec,templates,benchmarks}/**/*") + ['README.rdoc', 'Rakefile']
  s.require_paths = ['lib']
  s.has_rdoc      = 'yard'
end