// FTLabs Provisioning
// Provisioning Sequence
// 1. Scan QR Code
// 2. Connect to Semi Hotspot : CreateESP Device -> Connect to Semi Hotspot
// 3. Scan WiFi Networks
// 4. Provision Device
// 5. Connect to WiFi Network
// 6. Done
//

import React, {useState, useEffect} from 'react';
import {
  View,
  Text,
  Button,
  TextInput,
  ScrollView,
  NativeModules,
} from 'react-native';
import {Camera, CameraType} from 'react-native-camera-kit';

// import WifiManager from 'react-native-wifi-reborn';

const {ESP32IdfProvisioning} = NativeModules;

const ProvisionDeviceFTLabs = () => {
  const [device, setDevice] = useState(null);
  const [selectedDevice, setSelectedDevice] = useState(null);

  const [wifiList, setWifiList] = useState([]);

  const provisioningStages = [
    'Scan QR Code',
    'Connect to Semi Hotspot',
    'Scan WiFi Networks',
    'Provision Device',
    'Connect to WiFi Network',
    'Done',
  ];
  const [currentStage, setCurrentStage] = useState('Scan QR Code');

  const [selectedSSID, setSelectedSSID] = useState('');
  const [ssid, setSSID] = useState('');
  const [passphrase, setPassphrase] = useState('');

  const [scannedData, setScannedData] = useState(null);
  const [isScanning, setIsScanning] = useState(false);

  const [hostSsid, setHostSsid] = useState('');
  const [pop, setPop] = useState('');
  const [connectinResponse, setConnectinResponse] = useState('');
  const [wifiResponse, setWifiResponse] = useState('');
  const [provisionResponse, setProvisionResponse] = useState('');

  useEffect(() => {
    // searchDevices();
  }, []);

  console.log('ESP32IdfProvisioning', NativeModules.ESP32IdfProvisioning);

  const onSuccessfulConnection = device => {
    console.log('Connected to device:', device);
    setSelectedDevice(device);
    setCurrentStage('Scan WiFi Networks');
  };

  const onFailedConnection = error => {
    console.error('Failed to connect to device:', error);
  };

  const handleBarCodeRead = async event => {
    let parsedData;
    if (event.nativeEvent.codeStringValue) {
      setScannedData(event.nativeEvent.codeStringValue);
      setIsScanning(false);
      parsedData = JSON.parse(event.nativeEvent.codeStringValue);
      setPop(parsedData?.pop);
      setHostSsid(parsedData?.name);

      if (parsedData) {
        await ESP32IdfProvisioning.createESPDevice(
          parsedData.name,
          ESPTransport.softap,
          ESPSecurity.secure,
          parsedData.pop,
          null,
          null,
        )
          .then(data => {
            console.log('Device Created: ', data);
            setDevice(data);
            setCurrentStage('Connect to Semi Hotspot');
          })
          .catch(err => {
            console.log('Device Creation Failed: ', err);
          });

        connectToSemiHotspot(device);
        console.log(device, 'converted device ', parsedData);
        setDevice(device);
        setCurrentStage('Connect to Semi Hotspot');
        // setSelectedDevice(device)
        // setIsDeviceDetected(true);
      }
    }
  };

  const connectToSemiHotspot = async device => {
    // for (let step = 0; step < 1000; step++) {
    // Runs 5 times, with values of step 0 through 4.
    device.connect(pop, null, '').then(
      msg => {
        console.log('Connection Success: ', JSON.stringify(msg));
        setConnectinResponse(JSON.stringify(msg));
      },
      err => {
        console.log('step', 'connection failed : ', JSON.stringify(err));
        setConnectinResponse(JSON.stringify(err));
      },
    );
    // }
  };

  const scanWifiNetworks = async device => {
    // if (!selectedDevice) return;

    try {
      device
        .scanWifiList(device)
        .then(res => {
          console.log(JSON.stringify(res), 'wifififififififififififigifi');
          setWifiResponse(JSON.stringify(res));
        })
        .catch(err => {
          console.log(JSON.stringify(err), 'first scan errororororo');
          setWifiResponse(JSON.stringify(err));
        });
      setWifiList(wifiList);
    } catch (error) {
      console.error('Error scanning for WiFi networks:', JSON.stringify(error));
      setWifiResponse(JSON.stringify(error));
    }
  };

  const provisionDevice = async () => {
    if (!selectedDevice || !ssid || !passphrase) return;

    try {
      await selectedDevice.provision(ssid, passphrase);
      console.log('Device provisioned successfully.');
    } catch (error) {
      console.error('Error provisioning device:', JSON.stringify(error));
      setProvisionResponse(JSON.stringify(error));
    }
  };

  console.log(device, 'device');
  return (
    <View style={{padding: 20}}>
      <View>
        <Text>Provisioning </Text>
        {provisioningStages.map((stage, index) => (
          <Text
            key={index}
            style={{color: currentStage == stage ? 'green' : 'grey'}}>
            {index + 1}.{stage}
          </Text>
        ))}
        <Text style={{paddingTop: 20, color: 'green'}}>
          Current Stage: {currentStage}
        </Text>
      </View>
      {currentStage == 'Scan QR Code' && (
        <View style={{paddingTop: 20}}>
          <Camera
            ref={ref => (this.camera = ref)}
            style={{width: '100%', height: '70%'}}
            cameraType={CameraType.Back} // front/back(default)
            flashMode="auto"
            scanBarcode={true}
            onReadCode={handleBarCodeRead} // optional
            showFrame={false} // (default false) optional, show frame with transparent layer (qr code or barcode will be read on this area ONLY), start animation for scanner, that stops when a code has been found. Frame always at center of the screen
            // laserColor="red" // (default red) optional, color of laser in scanner frame
            // frameColor="white" // (default white) optional, color of border of scanner frame
          />
        </View>
      )}
      {currentStage == 'Connect to Semi Hotspot' && (
        <View>
          <Text style={{color: 'red'}}>Available Devices:</Text>
          {device && (
            <Button
              title={'Connect to ' + device.name}
              onPress={() => connectToDevice(device)}
              style={{width: 30, height: 30}}
            />
          )}
        </View>
      )}
      {currentStage == 'Scan WiFi Networks' && (
        <View style={{flex: 1}}>
          <Text>Selected Device: {device.name}</Text>
          <Button
            title="Scan WiFi Networks"
            onPress={() => scanWifiNetworks(device)}
          />
          <Text>Available WiFi Networks:</Text>
          {wifiList.map((network, index) => (
            <Text key={index}>{network.ssid}</Text>
          ))}
          <Text>SSID:</Text>
          <TextInput
            value={ssid}
            onChangeText={setSSID}
            placeholder="Enter SSID"
          />
          <Text>Passphrase:</Text>
          <TextInput
            value={passphrase}
            onChangeText={setPassphrase}
            placeholder="Enter Passphrase"
          />
          <Button title="Provision Device" onPress={provisionDevice} />
        </View>
      )}

      {scannedData && (
        <View>
          <Text>Scanned Data: {scannedData}</Text>
        </View>
      )}
      <View style={{paddingHorizontal: 20}}>
        <ScrollView>
          <View>
            <Text style={{color: 'red'}}>{wifiResponse}</Text>
            <Text style={{color: 'green'}}>{connectinResponse}</Text>
            <Text style={{color: 'blue'}}>{provisionResponse}</Text>
          </View>
        </ScrollView>
      </View>
    </View>
  );
};

export default ProvisionDeviceFTLabs;
