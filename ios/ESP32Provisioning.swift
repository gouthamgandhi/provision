//
//  ESP32Provisioning.swift
//  provision
//
//  Created by Goutham Gandhi Nadendla on 13/04/24.
//

import Foundation
import ESPProvision

@objc(ESP32Provisioning)
class ESP32Provisioning: NSObject {
    // Think we need to keep a dictionary of espDevices since we can't pass native
    // classes to react-native
    var espDevices: [String : ESPDevice] = [:]

    @objc(searchESPDevices:transport:security:resolve:reject:)
    func searchESPDevices(devicePrefix: String, transport: String, security: Int, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let transport = ESPTransport(rawValue: transport) ?? ESPTransport.ble
        let security = ESPSecurity(rawValue: security)

        self.espDevices.removeAll()
        
        var invoked = false
        ESPProvisionManager.shared.searchESPDevices(devicePrefix: devicePrefix, transport: transport, security: security) { espDevices, error in
            // Prevent multiple callback invokation error 
            guard !invoked else { return }

            if error != nil {
                reject("error", error?.description, nil)
                invoked = true
                return
            }

            espDevices?.forEach {
                self.espDevices[$0.name] = $0
            }

            resolve(espDevices!.map {[
                "name": $0.name,
                "advertisementData": $0.advertisementData ?? [],
                "capabilities": $0.capabilities ?? [],
                "security": $0.security.rawValue,
                "transport": $0.transport.rawValue,
                "username": $0.username as Any,
                "versionInfo": $0.versionInfo ?? {}
            ]})
            invoked = true
        }
    }

    @objc(stopESPDevicesSearch)
    func stopESPDevicesSearch() {
        ESPProvisionManager.shared.stopESPDevicesSearch()
    }

    @objc(createESPDevice:transport:security:proofOfPossession:softAPPassword:username:resolve:reject:)
    func createESPDevice(deviceName: String, transport: String, security: Int, proofOfPossession: String? = nil, softAPPassword: String? = nil, username: String? = nil, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let transport = ESPTransport(rawValue: transport) ?? ESPTransport.ble
        let security = ESPSecurity(rawValue: security)

        ESPProvisionManager.shared.createESPDevice(deviceName: deviceName, transport: transport, security: security, proofOfPossession: proofOfPossession
            , softAPPassword: softAPPassword, username: username) { espDevice, error in
            // Prevent multiple callback invokation error
            if error != nil {
                reject("error", error?.description, nil)
                return
            }

            resolve([
                "name": espDevice?.name,
                "advertisementData": espDevice?.advertisementData ?? [],
                "capabilities": espDevice?.capabilities ?? [],
                "security": espDevice?.security.rawValue,
                "transport": espDevice?.transport.rawValue,
                "username": espDevice?.username as Any,
                "versionInfo": espDevice?.versionInfo ?? {}
            ])
        }   

    }

    @objc(provisionDevice:pop:softAPPassword:resolve:reject:)
    func provisionDevice(deviceName: String, pop: String, softAPPassword: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        ESPProvisionManager.shared.provisionDevice(deviceName: deviceName, pop: pop, softAPPassword: softAPPassword) { espDevice, error in
            if error != nil {
                reject("error", error?.description, nil)
                return
            }

            resolve([
                "name": espDevice?.name,
                "advertisementData": espDevice?.advertisementData ?? [],
                "capabilities": espDevice?.capabilities ?? [],
                "security": espDevice?.security.rawValue,
                "transport": espDevice?.transport.rawValue,
                "username": espDevice?.username as Any,
                "versionInfo": espDevice?.versionInfo ?? {}
            ])
        }
    }

    @objc(getDeviceStatus:resolve:reject:)
    func getDeviceStatus(deviceName: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        ESPProvisionManager.shared.getDeviceStatus(deviceName: deviceName) { status, error in
            if error != nil {
                reject("error", error?.description, nil)
                return
            }

            resolve([
                "status": status.rawValue
            ])
        }
    }

    @objc(getWiFiList:resolve:reject:)
    func getWiFiList(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        ESPProvisionManager.shared.getWiFiList { wifiList, error in
            if error != nil {
                reject("error", error?.description, nil)
                return
            }

            resolve(wifiList!.map {[
                "ssid": $0.ssid,
                "rssi": $0.rssi,
                "auth": $0.auth.rawValue,
                "channel": $0.channel,
                "hidden": $0.isHidden,
                "bssid": $0.bssid
            ]})
        }
    }

    @objc(provision:ssid:passphrase:resolve:reject:)
    func provision(deviceName: String, ssid: String, passphrase: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if self.espDevices[deviceName] == nil {
            reject("error", "No ESP device found. Call createESPDevice first.", nil)
            return
        }

        var invoked = false
        self.espDevices[deviceName]!.provision(ssid: ssid, passPhrase: passphrase, completionHandler: { status in
            // Prevent multiple callback invokation error
            guard !invoked else { return }

            switch status {
            case .success:
                resolve([
                    "status": "success"
                ])
                invoked = true
            case .failure(let error):
                reject("error", error.description, nil)
                invoked = true
            case .configApplied:
                break
            }
        })
    }

}