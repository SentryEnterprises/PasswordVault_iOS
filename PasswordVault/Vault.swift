//
//  Vault.swift
//  PasswordVault
//

import Signals

class Vault {
    enum SyncStatus {
        case complete
        case encrypting
        case failed
        case transferring
    }

    static let dbPath = "/passwordvault/db.kdbx"
    static var kdbx: Kdbx?
    static var cardUUID: UUID? {
        get {
            guard let uuidString = UserDefaults.standard.string(forKey: "Vault.cardUUID") else {
                print("Vault.cardUUID not found")
                return nil
            }

            guard let uuid = UUID(uuidString: uuidString) else {
                print("Vault.cardUUID could not be converted to a UUID")
                return nil
            }

            return uuid
        }
        set {
            if let uuidString = newValue?.uuidString {
                UserDefaults.standard.set(uuidString, forKey: "Vault.cardUUID")
            } else {
                UserDefaults.standard.removeObject(forKey: "Vault.cardUUID")
            }
        }
    }

    static let syncStatus = Signal<Vault.SyncStatus>(retainLastData: true)
    static let syncQueue = DispatchQueue(label: "vaultSync")

    static func close() {
        kdbx = nil
    }

    static func create(password: String) {
        kdbx = Kdbx(password: password)
        Vault.syncStatus.fire(.complete)
    }

    static func open(encryptedData: Data, password: String) throws -> Kdbx {
        kdbx = try Kdbx(encryptedData: encryptedData, password: password)
        Vault.syncStatus.fire(.complete)
        return kdbx!
    }

    static func open(encryptedData: Data, compositeKey: [UInt8]) throws -> Kdbx {
        kdbx = try Kdbx(encryptedData: encryptedData, compositeKey: compositeKey)
        Vault.syncStatus.fire(.complete)
        return kdbx!
    }

    static func save() {
        Vault.syncQueue.async {
            guard let kdbx = kdbx else {
                return
            }

            guard let cardUUID = cardUUID else {
                return
            }

            guard let card = GKCard(uuid: cardUUID) else {
                return
            }

            let semaphore = DispatchSemaphore(value: 0)

            syncStatus.fire(.encrypting)

            let encryptedData: Data
            do {
                encryptedData = try kdbx.encrypt()
            } catch {
                print(error)
                return
            }

            GKCard.checkBluetoothState()
            .then {
                syncStatus.fire(.transferring)
            }
            .then {
                card.connect()
            }
            .then {
                card.put(data: encryptedData)
            }
            .then {
                card.checksum(data: encryptedData)
            }
            .then {
                card.close(path: Vault.dbPath)
            }
            .then {
                syncStatus.fire(.complete)
            }
            .always {
                card.disconnect().then {}
                semaphore.signal()
            }
            .catch { error in
                print(error)
                syncStatus.fire(.failed)
            }

            semaphore.wait()
        }
    }
}
