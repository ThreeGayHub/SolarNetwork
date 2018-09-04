Pod::Spec.new do |s|

  s.name = "SolarNetwork"
  s.version = "1.0.7"
  s.summary = "Elegant network abstraction layer in Swift."
  s.homepage = "https://github.com/ThreeGayHub/SolarNetwork"
  s.license = 'MIT'
  s.author = { "wyhazq" => "wyhazq@foxmail.com" }
  s.source = { :git => "https://github.com/ThreeGayHub/SolarNetwork.git", :tag => "#{s.version}" }
  
  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/*.swift'

  s.dependency      "Alamofire"

end
