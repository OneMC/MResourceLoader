
Pod::Spec.new do |s|
  s.name         = "MResourceLoader"
  s.version      = "0.0.1"
  s.summary      = "MResourceLoader use for AVPlayer loading resource"
  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/OneMC/MResourceLoader"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author       = { "MiaoChao" => "miaochaomc@163.com" }
  s.source       = { :git => "https://github.com/OneMC/MResourceLoader.git", :tag => "#{s.version}" }

  s.source_files = "MResourceLoader", "MResourceLoader/**/*.{h,m}"
  s.frameworks   = 'MobileCoreServices', 'AVFoundation'
  s.requires_arc = true
  s.platform     = ios, '9.0'
end
