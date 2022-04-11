#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint beacondart.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'beacondart'
  s.version          = '0.0.1'
  s.summary          = 'This project implements tezos beacon (tzip-10) in dart.'
  s.description      = <<-DESC
  This project implements tezos beacon (tzip-10) in dart.
                       DESC
  s.homepage         = 'https://github.com/EjaraApp/beacondart'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ejara' => 'baah.kusi@ejara.africa' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'BeaconCore'
  s.dependency 'BeaconClientWallet'
  s.dependency 'BeaconBlockchainSubstrate'
  s.dependency 'BeaconBlockchainTezos'
  s.dependency 'BeaconTransportP2PMatrix'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
