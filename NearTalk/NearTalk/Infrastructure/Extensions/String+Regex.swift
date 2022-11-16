//
//  String+Regex.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import Foundation

extension String {
    private func regexList(pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let founds = regex.matches(in: self, range: NSRange(self.startIndex ..< self.endIndex, in: self))
            return founds.compactMap {
                if let range = Range($0.range, in: self) {
                    return String(self[range])
                } else {
                    return nil
                }
            }
        } catch {
            return []
        }
    }
    
    func matchRegex(_ pattern: String) -> Bool {
        return !self.regexList(pattern: pattern).isEmpty
    }
}
