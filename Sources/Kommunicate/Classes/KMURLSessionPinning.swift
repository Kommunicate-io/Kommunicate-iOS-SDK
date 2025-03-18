//
//  KMURLSessionPinning.swift
//  Kommunicate
//
//  Created by Abhijeet Ranjan on 03/09/24.
//

import Foundation
import KommunicateCore_iOS_SDK
import CommonCrypto

class KMURLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    let rsa2048Asn1Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    private func sha256(data: Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(keyWithHeader.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
    func fetchExpectedPublicKeyHashes(from bundle: Bundle) -> [String]? {
        if let infoPlist = bundle.infoDictionary,
           let keys = infoPlist["KMExpectedPublicKeyHashBase64"] as? [String] {
            return keys
        } else if let plistPath = bundle.path(forResource: "KommunicateCore-Info", ofType: "plist"),
                  let infoPlist = NSDictionary(contentsOfFile: plistPath) as? [String: Any],
                  let keys = infoPlist["KMExpectedPublicKeyHashBase64"] as? [String] {
            return keys
        }
        return nil
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let bundle = ALUtilityClass.getBundle(),
           let kExpectedPublicKeyHashBase64 = fetchExpectedPublicKeyHashes(from: bundle) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secError: CFError?
                let isTrustValid = SecTrustEvaluateWithError(serverTrust, &secError)
                if isTrustValid {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        // Public key pinning
                        let serverPublicKey = SecCertificateCopyKey(serverCertificate)
                        let serverPublicKeyData: NSData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
                        let keyHash = sha256(data: serverPublicKeyData as Data)
                        if kExpectedPublicKeyHashBase64.contains(keyHash) {
                            // Success! This is our server
                            completionHandler(.useCredential, URLCredential(trust: serverTrust))
                            return
                        }
                    }
                }
            }
        }
        // Pinning failed
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
