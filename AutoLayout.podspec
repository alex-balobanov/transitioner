Pod::Spec.new do |s|
   s.name                  = "Transitioner"
   s.version               = "0.0.1"
   s.homepage              = "https://github.com/itlekt/transitioner"
   s.license               = { :type => 'MIT', :file => 'LICENSE' }
   s.author                = "Alex Balobanov"
   s.ios.deployment_target = "9.0"
   s.source               = { :git => "https://github.com/itlekt/transitioner.git", :tag => "#{s.version}" }
   s.source_files          = "Transitioner", "Transitioner/**/*.{h,m,swift}"
   s.requires_arc          = true
   s.summary               = "Custom transitions."
   s.description           = <<-DESC
       Custom view controller transitions framework.
   DESC
end
