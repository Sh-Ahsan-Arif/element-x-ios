import Foundation

final class BuildSettings: NSObject {
    static var applicationGroupIdentifier: String {
        "group.io.element"
    }

    static var baseBundleIdentifier: String {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            fatalError("bundleID should be defined")
        }
        return bundleID
    }

    static var keychainAccessGroup: String {
        guard let keychainAccessGroup = Bundle.main.object(forInfoDictionaryKey: "keychainAccessGroup") as? String else {
            fatalError("keychainAccessGroup should be defined")
        }
        return keychainAccessGroup
    }

    static var applicationURLScheme: String? {
        guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [AnyObject],
              let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
              let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
              let externalURLScheme = urlSchemes.first as? String else {
            return nil
        }

        return externalURLScheme
    }
}
