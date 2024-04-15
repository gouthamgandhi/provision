//
// Orbital Systems Implementation
//  provision
//
//  Created by Goutham Gandhi Nadendla on 13/04/24.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(ESP32Provisioning, RCTEventEmitter)

    RCT_EXTERN_METHOD(searchESPDevices:(NSString *)devicePrefix
                      transport:(NSString *)location
                      security:(NSInteger)security
                      resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject)

    RCT_EXTERN_METHOD(stopESPDevicesSearch)

    RCT_EXTERN_METHOD(createESPDevice:(NSString *)deviceName
                      transport:(NSString *)transport
                      security:(NSInteger)security
                      proofOfPossession:(NSString *)proofOfPossession
                      softAPPassword:(NSString *)softAPPassword
                      username:(NSString *)username
                      resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject)

    RCT_EXTERN_METHOD(connect:(NSString *)deviceName
                      resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject)

    RCT_EXTERN_METHOD(scanWifiList:(NSString *)deviceName
                      resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject)

    RCT_EXTERN_METHOD(disconnect:(NSString *)deviceName)

    RCT_EXTERN_METHOD(provision:(NSString *)deviceName
                      ssid:(NSString *)ssid
                      passphrase:(NSString *)passphrase
                      resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject)

@end
