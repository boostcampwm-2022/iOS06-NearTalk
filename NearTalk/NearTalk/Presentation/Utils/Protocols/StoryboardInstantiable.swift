//
//  StoryboardInstantiable.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/21.
//

import UIKit

public protocol StoryboardInstantiable: NSObjectProtocol {
    associatedtype ObjectType
    
    static var defaultFileName: String { get }
    static func instantiateViewController(_ bundle: Bundle?) -> ObjectType
}

public extension StoryboardInstantiable where Self: UIViewController {
    static var defaultFileName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    static func instantiateViewController(_ bundle: Bundle? = nil) -> Self {
        let fileName = defaultFileName
        let storyboard = UIStoryboard(name: fileName, bundle: bundle)
        guard let vc = storyboard.instantiateInitialViewController() as? Self else {
            
            fatalError("Cannot instantiate initial view controller \(Self.self) from storyboard with name \(fileName)")
        }
        return vc
    }
}
