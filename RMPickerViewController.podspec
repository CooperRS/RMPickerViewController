Pod::Spec.new do |s|
  s.name         = "RMPickerViewController"
  s.version      = "2.3.0"
  s.platform     = :ios, "8.0"
  s.summary      = "This is an iOS control for selecting something using UIPickerView in a UIAlertController like fashion"
  s.description  = "This framework allows you to pick something with a picker presented as an action sheet. In addition, it allows you to add actions arround the presented picker which behave like a button and can be tapped by the user. The result looks very much like an UIActionSheet or UIAlertController with a UIPickerView and some UIActions attached."

  s.homepage     = "https://github.com/CooperRS/RMPickerViewController"
  s.screenshots  = "http://cooperrs.github.io/RMPickerViewController/images/Blur-Screen1.png", "http://cooperrs.github.io/RMPickerViewController/images/Blur-Screen2.png", "http://cooperrs.github.io/RMPickerViewController/images/Blur-Screen3.png"
  
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Roland Moers" => "rm@cooperrs.de" }
  
  s.source       = { :git => "https://github.com/CooperRS/RMPickerViewController.git", :tag => "2.3.0" }
  s.source_files = 'RMPickerViewController/*.{h,m}'
  s.requires_arc = true
  
  s.dependency   'RMActionController', '~> 1.2.1'
end
