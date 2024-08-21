import Foundation

public enum API {
    private static let zeroURLRoot = "https://zos-api-development-fb2c513ffa60.herokuapp.com/"
    private static let version = "v2"
    public static let matrixURLString = "https://zero-staging-new-9476d8d7e22a.herokuapp.com" // "https://zosapi.zero.tech" // https://zos-home-1-f552c502c7d6.herokuapp.com"
    public static let redirectedMatrixURLString = "https://zos.zer0.io"
    public static let matrixUserSuffix = ":zos-home-2.zero.tech"
    public static let pushServerURL = "https://zos-push-gateway-development-6477b312dabd.herokuapp.com/_matrix/push/v1/notify"
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
