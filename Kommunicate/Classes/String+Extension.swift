//
//  Kommunicate+Helper.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 19/06/18.
//

import Foundation

extension String {

    static func random(length: Int = 10) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }

    var isValidPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let result = matches.first {
                return result.resultType == .phoneNumber && result.range.location == 0 && result.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }

    /// Checks if email is in this format: xyz@abc.de
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }

    func matchesWithPattern(_ pattern: String) -> Bool {
        let numberPredicate = NSPredicate(format:"SELF MATCHES %@", pattern)
        return numberPredicate.evaluate(with: self)
    }
}

extension String {
    var containsWhitespace: Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
}
