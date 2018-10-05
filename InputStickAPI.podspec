Pod::Spec.new do |s|
  s.name         = "InputStickAPI"
  s.version      = "1.0"
  s.summary      = "InputStickAPI"
  s.homepage     = "https://github.com/inputstick/InputStickAPI-iOS"
  s.author       = { "Jakub Zawadzki" => "jzawadzki@inputstick.com" }
  s.source       = { :git => "https://github.com/inputstick/InputStickAPI-iOS.git", :tag => '1.0' }
  s.requires_arc = true
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }

  s.ios.deployment_target  = '9.0'
  s.tvos.deployment_target  = '9.0'

  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |cs|
  	cs.source_files = 'InputStickAPI/**/*.{h,m}'

  	cs.ios.dependency 'MBProgressHUD', '~> 1.1.0'
  	
  end

end
