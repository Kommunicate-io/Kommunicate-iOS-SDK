import class Foundation.Bundle

extension Foundation.Bundle {
    static var module: Bundle = {
        let mainPath = Bundle.main.bundlePath + "/" + "Kommunicate-iOS-SDK_Kommunicate-iOS-SDK.bundle"
        let buildPath = "/Users/rentomojo/Documents/Kommunicate-iOS-SDK/.build/x86_64-apple-macosx/debug/Kommunicate-iOS-SDK_Kommunicate-iOS-SDK.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle != nil ? preferredBundle : Bundle(path: buildPath) else {
            fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}