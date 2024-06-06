//
//  ContentView.swift
//  jetbeepLocker
//
//  Created by Max Tymchii on 20.12.2023.
//

import SwiftUI
import JetbeepLockerSDK
import Combine

/***
 - Start scan / Stop Scan button
 - List of founded devices
 - Connect to device / Disconnect from device
 - Device info request :
 - none
 - project key
 - device key
 - validate signature
 - Enable encryption
 - Open lock with password
 */

@Observable
class LockerManagerModel {

    var cancelable = Set<AnyCancellable>()

    let flow = LockerFlow()
    var devices: [LockerDevice] = []
    var connectedDevices: [LockerDevice] = []
    var path = NavigationPath()
    var isScanning = false
    var showEnableBluettothNotification: Bool = false

    var bluetoothStatusManager: BluettothStatusManager = BluettothStatusManager()

    init() {
        setupConfiguration()

        flow.deviceStatusPublishers
            .receive(on: DispatchQueue.main)
            .sink {[weak self] event in
                switch event {
                case .found:
                    self?.devices = self?.flow.nearbyDevices ?? []
                case let .lost(device):
                    print("Lost device: \(device.peripheralState)")
                    if (self?.path.count ?? 0) > 0 {
                        self?.path.removeLast()
                    }
                    self?.connectedDevices.removeAll { $0.deviceId == device.deviceId }
                    self?.devices.removeAll { $0.deviceId == device.deviceId }

                case let .update(device):
                    switch device.peripheralState {
                    case .connected, .connecting, .disconnecting:
                        break
                    case .disconnected:
                        if (self?.path.count ?? 0) > 0 {
                            self?.path.removeLast()
                        }
                        self?.connectedDevices.removeAll { $0.deviceId == device.deviceId }
                    }

                }
            }
            .store(in: &cancelable)

        bluetoothStatusManager
            .bluetoothStatus
            .sink { status in
                if case .bluetoothOn = status {
                    self.showEnableBluettothNotification = false
                } else {
                    self.showEnableBluettothNotification = true
                }
            }
            .store(in: &cancelable)

    }

    func setupConfiguration() {
        do {
            let configuaration = try LockerSDKConfiguration()
                .addProjectId(1)
                .addLogLevel(.info)
                .build()

            LockerSDK.shared = .instantiate(with: configuaration)

            logger.publisher.sink { event in
                print("\(event)")
            }.store(in: &cancelable)

        } catch {
            print("Error \(error)")
        }
    }

    func isDeviceConnected(_ device: LockerDevice) -> Bool {
        connectedDevices.contains(device)
    }

    func connect(to device: LockerDevice) {
        Task {
            do {
                try await flow.connect(to: device)

                await MainActor.run {
                    connectedDevices.append(device)
                    let lockerDeviceModel = LockerDeviceModel()
                    lockerDeviceModel.flow = flow
                    path.append(lockerDeviceModel)
                }

                print("Connected to \(device)")
            } catch {
                print("Error \(error)")
            }
        }
    }

    func disconnect(from device: LockerDevice) {
        Task {
            do {
                try await flow.disconnect(from: device)
                await MainActor.run {
                    connectedDevices.removeAll { $0.deviceId == device.deviceId }
                }
            } catch {
                print("Error \(error)")
            }
        }
    }

    func tapOnScanButton() {
        if isScanning {
            _ = flow.stop()
        } else {
            do {
                _ = try flow.start()
            } catch {
                print("Error \(error)")
            }
        }
    }
}

struct DeviceView: View {
    let deviceId: String
    let userData: String
    let isConnected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text("Device id: \(deviceId)")
                .font(.title2)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 12)

            Text("User Data: \(userData)")
                .font(.title3)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        .background(isConnected ? .blue.opacity(0.3) : .green.opacity(0.3))
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    DeviceView(deviceId: "123", userData: "1,2,3,4,5,6", isConnected: true)
}

struct LockerManager: View {
    @Bindable var model = LockerManagerModel()

    var body: some View {
        NavigationStack(path: $model.path) {
            ZStack {
                if model.showEnableBluettothNotification {
                    enableBluettothNotification
                }
                ScrollView(.vertical) {
                    listView

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 100)

                if !model.showEnableBluettothNotification {
                    scanButton
                }
            }
            .background(Color.mint.opacity(0.2))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Jetbeep Lockers")
            .navigationDestination(for: LockerDeviceModel.self) { model in
                LockerDeviceView(model: model)
            }
        }
    }
    var scanButton: some View {
        VStack {
            Spacer()
            Button(model.isScanning ? "Stop Scan" : "Start Scan") {
                model.tapOnScanButton()
                model.isScanning.toggle()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
            .foregroundColor(.green)
            .buttonStyle(GrowingButton(isScan: $model.isScanning))
        }
        .frame(maxWidth: .infinity)
    }
    var enableBluettothNotification: some View {
        VStack {
            Spacer()
            Text("Please enable bluetooth")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .padding()

            Image(systemName: "wifi.slash")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            Spacer()
            Spacer()
        }
    }

    var listView: some View {
        ForEach(model.devices, id: \.deviceId) { device in
            DeviceView(deviceId: device.deviceId.description,
                       userData: device.userData.description,
                       isConnected: model.isDeviceConnected(device))
                .onTapGesture {
                    if model.isDeviceConnected(device) {
                        model.disconnect(from: device)
                    } else {
                        model.connect(to: device)
                    }
                }
        }
    }

}

#Preview {
    LockerManager()
}
