//
//  LockerDeviceView.swift
//  jetbeepLocker
//
//  Created by Max Tymchii on 29.03.2024.
//

import SwiftUI
import JetbeepLockerSDK

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}

extension View {
    func card() -> some View {
        self.modifier(CardModifier())
    }
}

@Observable
class LockerDeviceModel {

    enum DeviceInfoRequest: String, CaseIterable {
        case none
        case projectKey
        case deviceKey

        var deviceInfoRequestType: DeviceInfoRequestType {
            switch self {
            case .none:
                return .none
            case .projectKey:
                return .projectKey
            case .deviceKey:
                return .projectDeviceKey
            }
        }
    }

    enum EncryptionState {
        case enabled
        case inProgress
        case disabled

        var image: String {
            switch self {
            case .enabled:
                return "lock.fill"
            case .inProgress:
                return "point.3.connected.trianglepath.dotted"
            case .disabled:
                return "lock.open"
            }
        }
    }

    let id: UUID = UUID()

    var flow: LockerFlow?

    var encryptionState: EncryptionState = .disabled
    var password: String = ""
    var deviceInfoRequest: DeviceInfoRequest = .none
    var validationPublicKey: String = ""
    var requestResult: AnyResult?

    func enableEncryption() {
        guard encryptionState == .disabled else {
            return
        }

        encryptionState = .inProgress
        Task {
            do {
                guard let flow = flow else {
                    return
                }

                try await flow.enableEncryption()

                await MainActor.run {
                    self.encryptionState = .enabled
                }
            } catch {
                print("Error \(error)")
                requestResult = AnyResult(error)
            }
        }
    }

    func openLock() {
        print("Open lock with password: \(password)")
        guard let password = UInt64(password) else {
            return
        }

        Task {
            do {
                guard let flow = flow else {
                    return
                }

                let result = try await flow.openLock(with: password)
                print("Open lock response: \(result)")
                requestResult = AnyResult(result)
            } catch {
                requestResult = AnyResult(error)
                print("Error \(error)")
            }
        }
    }

    func requestDeviceInfo() {
        print("Request device info: \(deviceInfoRequest)")
        Task {
            do {
                guard let flow = flow else {
                    return
                }

                let result = try await flow.getDeviceInfo(requestType: deviceInfoRequest.deviceInfoRequestType)

                switch deviceInfoRequest {
                case .none:
                    requestResult = AnyResult(result)
                case .projectKey:
                    let isValid = try self.validateSignature(result)
                    requestResult = AnyResult(DeviceInfoWithValidation(deviceInfo: result,
                                                                       isSignatureValid: isValid))
                case .deviceKey:
                    let isValid = try self.validateSignature(result)
                    requestResult = AnyResult(result)
                }

            } catch {
                print("Error \(error)")
                requestResult = AnyResult(error)
            }
        }
    }

    private func validateSignature(_ deviceInfo: DeviceInfo) throws -> Bool {
        let publicKey: [UInt8] = validationPublicKey
            .components(separatedBy: " ")
            .compactMap { UInt8($0, radix: 16) }

        return try deviceInfo.validateSignatureWithPublic(key: Data(publicKey))
    }
}

extension LockerDeviceModel: Hashable {
    static func == (lhs: LockerDeviceModel, rhs: LockerDeviceModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct LockerDeviceView: View {
    @Bindable var model: LockerDeviceModel

    init(model: LockerDeviceModel) {
        self._model = Bindable(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                deviceInfoRequest
                openLock
                enableEncryption
            }
            .ignoresSafeArea(.keyboard)

        }
        .padding()
        .ignoresSafeArea(.keyboard)
        .navigationTitle("Locker Device")

        .scrollDismissesKeyboard(.immediately)
        .sheet(item: $model.requestResult) { result in
            ResultView(result)
                .presentationDetents([.medium, .large])
        }
    }

    var enableEncryption: some View {
        HStack {
            Text("Enable encryption")
            Spacer()
            Button {
                withAnimation {
                    model.enableEncryption()
                }
            } label: {
                Image(systemName: model.encryptionState.image)
            }
            .contentTransition(.symbolEffect(.replace))
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .frame(height: 50)
        .card()
    }

    var openLock: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Input public key for validation (base64 format)")
                .font(.caption)

            TextField("Password", text: $model.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button {
                model.openLock()
            } label: {
                Text("Open lock")
                    .font(.title3)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .frame(height: 40)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .card()
    }

    var deviceInfoRequest: some View {

        VStack(spacing: 16) {

            Picker("",
                   selection: $model.deviceInfoRequest) {
                ForEach(LockerDeviceModel.DeviceInfoRequest.allCases, id: \.self) {
                    Text($0.rawValue)
                }

            }.pickerStyle(.segmented)

            if model.deviceInfoRequest != .none {
                VStack(alignment: .leading) {
                    Text("Input public key for validation (base64 format)")
                        .font(.caption)
                    TextField("Public key", text: $model.validationPublicKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }

            Button {
                model.requestDeviceInfo()
            } label: {
                Text("Request devide info")
                    .font(.title3)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .frame(height: 40)
            }
            .buttonStyle(.borderedProminent)

        }
        .card()

    }
}

#Preview {
    LockerDeviceView(model: LockerDeviceModel())
}
