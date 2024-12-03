platform :ios, '14.0'

workspace 'ios-sdk-sample.xcworkspace'
use_frameworks!

module 'SampleAppShared'
project 'merchant-managed-payment/merchant-managed-payment.xcodeproj'
project 'link-managed-payment/link-managed-payment.xcodeproj'

abstract_target 'ios-sdk-sample' do
    pod 'LinkAccount', '~> 3.0.2'

    target 'merchant-managed-payment' do
        project 'merchant-managed-payment/merchant-managed-payment.xcodeproj'
    end

    target 'link-managed-payment' do 
        project 'link-managed-payment/link-managed-payment.xcodeproj'
    end
end
