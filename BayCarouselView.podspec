Pod::Spec.new do |s|

  s.name         = "BayCarouselView"
  s.version      = "0.0.1"
  s.summary      = "A Carousel View."

  s.homepage     = "https://git.17bdc.com/pupboss/BayCarouselView"
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.license      = {:type => 'Copyright', :text =>
    <<-LICENSE
      Shanbay.com Copyright © 2009-2016
    LICENSE
  }

  s.author       = { 'Shanbay iOS' => 'ios@shanbay.com' }

  s.source       = { :git => "https://git.17bdc.com/pupboss/BayCarouselView", :tag => "#{s.version}" }

  s.source_files  = "Classes", "BayCarouselView/BayCarouselView/*.{h,m}"

end
