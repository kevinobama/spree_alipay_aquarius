# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'spree_alipay_payment/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_alipay_payment'
  s.version     = SpreeAlipayPayment::VERSION
  s.summary     = 'Adds Alipay Payment as a Payment Method to Spree Commerce'
  s.description = s.summary
  s.required_ruby_version = '>= 1.9.3'

  s.author       = 'kevin obama'
  s.email        = 'w.zhou@aquarius-asia.com'
  s.homepage     = 'http://g.uboxi.com/'
  s.license      = %q{BSD-3}

  s.files        = Dir.glob("{app,config,lib}/**/*")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '>= 2.3.0'
  s.add_dependency 'alipay', "0.1.0"

end