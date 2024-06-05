#
#  Be sure to run `pod spec lint JetbeepLockerSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
# #"https://github.com/jetbeep/ios-sdk/raw/master/JetBeepFramework-1.0.126.zip"
#  'file:///Users/samback/Projects/jetbeep/JetbeepLockerSDK/Releases/JetbeepLockerSDK.zip', :flatten => false

Pod::Spec.new do |s|
	s.name              = 'JetbeepLockerSDK'
	s.version           = "1.0.0"
	s.summary           = 'Jetbeep locker SDK for proper work with Jetbeep locker devices.'
	s.homepage          = 'https://github.com/jetbeep/locker-sdk-ios'

	s.author            = { "Oleh Hordiichuk" => "oleh.hordiichuk@jetbeep.com"  }
	s.license           = { :type => 'The MIT License (MIT)', :file => 'LICENSE.txt' }
	s.source            = { :http => 'https://github.com/jetbeep/locker-sdk-ios/raw/main/Releases/LockerSDK-1.0.0.zip' }
	

	s.platform          = :ios
	s.swift_version     = '5.0'
	
	s.dependency 'CryptoSwift', '~> 1.8.2'
	s.dependency 'SwiftProtobuf', '~> 1.0'


	s.ios.deployment_target = '13.0'
	s.vendored_frameworks = 'JetbeepLockerSDK.xcframework'

end
