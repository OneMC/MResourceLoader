
Pod::Spec.new do |s|

  s.name         = "MResourceLoader"

  s.version      = "0.0.2"

  s.summary      = "MResourceLoader use for AVPlayer loading resource"

  s.homepage     = "https://github.com/OneMC/MResourceLoader"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "MiaoChao" => "miaochaomc@163.com" }
  
  s.source       = { :git => "https://github.com/OneMC/MResourceLoader.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.source_files = "MResourceLoader", "MResourceLoader/**/*.{h,m}"
  s.frameworks   = 'MobileCoreServices', 'AVFoundation'


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true
  s.platform     = :ios, '6.0'

end
