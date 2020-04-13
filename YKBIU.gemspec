
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "YKBIU/version"

Gem::Specification.new do |spec|
  spec.name          = "YKBIU"
  spec.version       = YKBIU::VERSION
  spec.authors       = ["wanyakun"]
  spec.email         = ["wanyakun@vip.qq.com"]

  spec.summary       = %q{iOS应用依赖管理gem.}
  spec.description   = %q{用来处理iOS应用的CocoaPods依赖关系，根据远程依赖配置数据自动安装配置.}
  spec.homepage      = "http://github.com/wanyakun/YKBIU"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "cocoapods"
  spec.add_development_dependency "fastlane"
  spec.add_development_dependency "dotenv"
end
