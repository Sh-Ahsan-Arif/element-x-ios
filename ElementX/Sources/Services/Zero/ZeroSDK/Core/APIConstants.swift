import Foundation

public enum API {
    private static let zeroURLRoot = "https://zosapi.zero.tech"
    private static let version = "v2"
    public static let matrixURLString = "https://zos-home-2-e24b9412096f.herokuapp.com" // "https://zosapi.zero.tech" // https://zos-home-1-f552c502c7d6.herokuapp.com"
    public static let redirectedMatrixURLString = "https://zos.zer0.io"
    public static let matrixUserSuffix = ":zos-home-2.zero.tech"
    public static let pushServerURL = "https://zos-push-gateway-c101e2f4da49.herokuapp.com/_matrix/push/v1/notify"
    public static let isProduction = true

    // #endif

    public static let zeroURLString = "\(zeroURLRoot)/api/\(version)/"
    // "profile-background" vs "avatar" <-- From the old app.  When we get around to uploading profile backgrounds, use the right path.
    public static let profileImageUploadURLString = "\(zeroURLRoot)/upload/avatar"
    public static let createAccountURL = "\(redirectedMatrixURLString)/get-access"
}

public enum Settings {
    public static let accessTokenKey = "AccessTokenKey"
    public static let web3TokenKey = "web3TokenKey"
    public static let passwordKey = "PassworKey"
    public static let emailKey = "EmailKey"
    public static let backupKey = "backupKey"
}
