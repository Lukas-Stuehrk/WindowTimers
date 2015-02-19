Pod::Spec.new do |s|
  s.name             = "WindowTimers"
  s.version          = "0.1.0"
  s.summary          = "An implementation of the JavaScript WindowTimers to extend JavaScriptCore."
  s.description      = <<-DESC
                        In iOS 7, Apple introduced the possibility to [execute JavaScript via the JavaScriptCore JavaScript engine]
                        (http://nshipster.com/javascriptcore/). Unfortunately, JavaScriptCore is missing some objects and functions a browser
                        JavaScript environment would have. Especially the methods described in the [WindowTimers specification]
                        (https://html.spec.whatwg.org/multipage/webappapis.html#windowtimers), such as `setTimeout` or `setInterval` are not
                        provided. This library implements those methods, so it is possible to use JavaScript libraries which were originally
                        developed for in-browser use in your Objective-C (or Swift) application without the need to use a hidden WebView.
                       DESC
  s.homepage         = "https://github.com/Lukas-Stuehrk/WindowTimers"
  s.license          = 'MIT'
  s.author           = { "Lukas Stührk" => "Lukas@Stuehrk.net" }
  s.source           = { :git => "https://github.com/Lukas-Stuehrk/WindowTimers.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'WindowTimers/WindowTimers.*'
  s.resource_bundles = {
  }

  s.public_header_files = 'WindowTimers/WindowTimers.h'
  s.frameworks = 'JavaScriptCore'
end
