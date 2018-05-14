$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "sneakers_pg"
  s.version     = "0.0.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dmitrii Golub"]
  s.email       = ["dmitrii.golub@gmail.com"]
  s.summary     = %q{}
  s.description = %q{}

  s.require_paths = ["lib"]

  s.add_dependency "sneakers", ">= 2.7.0"
end
