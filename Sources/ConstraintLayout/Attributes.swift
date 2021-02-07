//
//  File.swift
//  
//
//  Created by Benjamin Pious on 2/7/21.
//

public struct Leading: LayoutAttributeWord {
    
    static let attribute: Constraint.Attribute = .leading
    
}

public struct Trailing: LayoutAttributeWord {
    
    static let attribute: Constraint.Attribute = .trailing
    
}

protocol LayoutAttributeWord {
    
    static var attribute: Constraint.Attribute { get }
    
}

extension LayoutAttributeWord {
    
    public static func equalTo(_ layoutItem: LayoutItem) -> ConstraintBuilder {
        var builder = ConstraintBuilder(firstAttribute: attribute,
                                        relationShip: .equalTo)
        layoutItem.apply(to: &builder)
        return builder
    }
    
    public static func greaterThan(_ layoutItem: LayoutItem) -> ConstraintBuilder {
        var builder = ConstraintBuilder(firstAttribute: attribute,
                                        relationShip: .greaterThan)
        layoutItem.apply(to: &builder)
        return builder
    }
    
    public static func lessThan(_ layoutItem: LayoutItem) -> ConstraintBuilder {
        var builder = ConstraintBuilder(firstAttribute: attribute,
                                        relationShip: .greaterThan)
        layoutItem.apply(to: &builder)
        return builder
    }



}
