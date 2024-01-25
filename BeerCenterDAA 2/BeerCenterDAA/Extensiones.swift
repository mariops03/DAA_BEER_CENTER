import UIKit
import Foundation
import AVFoundation


extension String {
    var isValidURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.endIndex.utf16Offset(in: self))) {
            return match.range.length == self.endIndex.utf16Offset(in: self)
        } else {
            return false
        }
    }
}

