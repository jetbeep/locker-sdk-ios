//
//  BluettothStatusManager.swift
//  jetbeepLocker
//
//  Created by Max Tymchii on 11.04.2024.
//

import Foundation
import CoreBluetooth
import Combine
import JetbeepLockerSDK

final class BluettothStatusManager: NSObject {
    private var centralManager: CBCentralManager?
    private let bluetoothStatusSubject = CurrentValueSubject<BluetoothStatus, Never>(.bluetoothOff)

    var bluetoothStatus: AnyPublisher<BluetoothStatus, Never> {
        bluetoothStatusSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self,
                                               queue: nil,
                                               options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }
}

extension BluettothStatusManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let status = BluetoothStatus(rawValue: central.state)
        bluetoothStatusSubject.send(status)
    }
}
