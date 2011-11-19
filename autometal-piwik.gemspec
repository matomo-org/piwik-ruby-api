# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{autometal-piwik}
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Achillefs Charmpilas"]
  s.date = %q{2011-01-18}
  s.description = %q{A simple Ruby client for the Piwik API. This gem is based on Rodrigo Tassinari de Oliveira's piwik gem (https://github.com/riopro/piwik). Since it hasn't been updated since 2008, I took the liberty to fork it, and finish it up.}
  s.email = ["ac@humbuckercode.co.uk"]
  s.extra_rdoc_files = ["License.txt", "Manifest.txt", "PostInstall.txt", "Todo.txt"]
  s.files = ["License.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "Todo.txt", "autometal-piwik.gemspec", "lib/piwik.rb", "lib/piwik/base.rb", "lib/piwik/site.rb", "lib/piwik/trackable.rb", "lib/piwik/user.rb", "script/console", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "test/files/config/piwik.yml", "test/piwik_test.rb", "test/test_helper.rb"]
  s.homepage = %q{https://github.com/Achillefs/autometal-piwik}
  s.post_install_message = %q{
For more information on piwik, see http://piwik.rubyforge.org or 
https://github.com/Achillefs/autometal-piwik

}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{autometal-piwik}
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{A simple Ruby client for the Piwik API}
  s.test_files = ["test/test_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.8"])
      s.add_runtime_dependency(%q<xml-simple>, [">= 1.0.11"])
      s.add_runtime_dependency(%q<rest-client>, [">= 1.6.1"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.8"])
      s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
      s.add_dependency(%q<rest-client>, [">= 1.6.1"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe>, [">= 2.6.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.8"])
    s.add_dependency(%q<xml-simple>, [">= 1.0.11"])
    s.add_dependency(%q<rest-client>, [">= 1.6.1"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe>, [">= 2.6.2"])
  end
end
