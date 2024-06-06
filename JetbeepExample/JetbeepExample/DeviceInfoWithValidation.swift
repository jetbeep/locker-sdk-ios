//
//  DeviceInfoWithValidation.swift
//  jetbeepLocker
//
//  Created by Max Tymchii on 02.04.2024.
//

import Foundation
import JetbeepLockerSDK

public struct DeviceInfoWithValidation {
    private let deviceInfo: DeviceInfo
    private let isSignatureValid: Bool

    init(deviceInfo: DeviceInfo, isSignatureValid: Bool) {
        self.deviceInfo = deviceInfo
        self.isSignatureValid = isSignatureValid
    }
}
