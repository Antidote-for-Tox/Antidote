source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

# ignore all warnings from all pods
inhibit_all_warnings!

def common_pods
    pod 'objcTox', :git => 'https://github.com/Antidote-for-Tox/objcTox.git', :commit => '2e77d1d8dc7415b3b4f2e38cd2ab382a3025e0bd'
    pod 'UITextView+Placeholder', '~> 1.1.0'
    pod 'SDCAlertView', '~> 2.5.4'
    pod 'LNNotificationsUI', :git => 'https://github.com/LeoNatan/LNNotificationsUI.git', :commit => '3f75043fc6e77b4180b76cb6cfff4faa506ab9fc'
    pod 'JGProgressHUD', '~> 1.4.0'
end

target :Antidote do
    common_pods
end

target :AntidoteTests do
    common_pods
    pod 'FBSnapshotTestCase/Core'
end
