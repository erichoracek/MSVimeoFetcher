Pod::Spec.new do |s|
  s.name         = 'MSVimeoFetcher'
  s.version      = '0.0.1'
  s.license      = 'MIT'
  s.platform     = :ios, '5.0'
  
  s.summary      = 'MSVimeoFetcher fetches the vimeo mp4 URL from a standard vimeo URL'
  s.homepage     = 'https://github.com/monospacecollective/MSVimeoFetcher'
  s.author       = { 'Eric Horacek' => 'eric@monospacecollective.com' }
  s.source       = { :git => 'https://github.com/monospacecollective/MSVimeoFetcher.git', :tag => s.version.to_s }

  s.source_files = 'MSVimeoFetcher/*.{h,m}'
  
  s.requires_arc = true
  
  s.dependency 'AFNetworking'
end
