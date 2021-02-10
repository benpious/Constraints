//
//  Copyright (c) 2021. Ben Pious
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

/**
 A constraint under construction.
 
 You mutate this object through the DSL, or when `apply(to:)` is called by the DSL on
 your custom type.
 
 There is no need to interact with this class directly except for in the latter scenario.
 */
public struct ConstraintBuilder: LayoutComponent {
        
    let first: AnyObject
    let firstAttribute: Constraint.Attribute
    var second: Constraint.SecondItem? = nil
    var secondAttribute: Constraint.Attribute = .noAttribute
    var constant: CGFloat = 0
    var multiple: CGFloat = 1
    var relationShip: Constraint.Relation
    var priority: Float = 1000
    
    func makeConstraint() -> Constraint {
        .init(
            first: first,
            firstAttribute: firstAttribute,
            second: second,
            secondAttribute: secondAttribute,
            constant: constant,
            multiple: multiple,
            relationShip: relationShip,
            priority: priority
        )
    }
    
    public func priority(_ priority: Float) -> Self {
        var new = self
        new.priority = priority
        return new
    }
    
    public func offset(_ offset: CGFloat) -> Self {
        var new = self
        new.constant = offset
        return new
    }
    
    public func multiply(by multiple: CGFloat) -> Self {
        var new = self
        new.multiple = multiple
        return new
    }
    
    public var constraints: [Constraint] {
        [makeConstraint()]
    }
}

/**
 Edge constraints under construction.
 
 You mutate this object through the DSL, or when `apply(to:)` is called by the DSL on
 your custom type.
 
 There is no need to interact with this class directly except for in the latter scenario.
 */
public struct EdgesConstraintBuilder: LayoutComponent {
    
    let first: AnyObject
    var second: Constraint.SecondItem? = nil
    var constant: CGFloat = 0
    var multiple: CGFloat = 1
    var relationShip: Constraint.Relation
    var priority: Float = 1000
    let attributes: Set<Constraint.Attribute>
    
    init(first: AnyObject,
         relationShip: Constraint.Relation,
         attributes: Set<Constraint.Attribute>) {
        self.first = first
        self.relationShip = relationShip
        self.attributes = attributes
    }
    
    public var constraints: [Constraint] {
        attributes
            .map { ($0, $0.sign(constant) )}
            .map { attribute, constant in
                Constraint(first: first,
                           firstAttribute: attribute,
                           second: second,
                           secondAttribute: attribute,
                           constant: constant,
                           multiple: multiple,
                           relationShip: relationShip,
                           priority: priority)
            }
    }
    
}


extension Constraint.Attribute {
    
    var sign: (CGFloat) -> (CGFloat) {
        switch self {
        case .trailing, .bottom: return (-)
        default:
            func identity(_ float: CGFloat) -> CGFloat {
                float
            }
            return identity(_:)
        }
    }
    
}

