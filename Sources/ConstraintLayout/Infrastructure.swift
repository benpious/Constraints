//
//  File.swift
//  
//
//  Created by Benjamin Pious on 2/7/21.
//

public protocol LayoutOptionalProtocol {
    
    associatedtype Wrapped
    
    var ___wrapped: Wrapped? { get }
    
}

extension Optional: LayoutOptionalProtocol {
    
    public var ___wrapped: Wrapped? {
        self
    }
    
}
