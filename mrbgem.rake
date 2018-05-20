MRuby::Gem::Specification.new('mrubyc-utils') do |spec|
  spec.license = 'MIT'
  spec.author  = 'MRuby Developer'
  spec.summary = 'mrubyc-utils'
  spec.bins    = ['mrubyc-utils']

  spec.add_dependency 'mruby-print', :core => 'mruby-print'
  spec.add_dependency 'mruby-mtest', :mgem => 'mruby-mtest'
end
