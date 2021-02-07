import UIKit

/**
 The DSL. Do not interact with this class directly.
 */
@_functionBuilder
public struct LayoutBuilder {
        
    public typealias Component = LayoutComponent
    
    public static func buildBlock(_ components: Component...) -> Component {
        buildArray(components)
    }
    
    public static func buildEither(first component: Component) -> Component {
        component
    }
    
    public static func buildEither(second component: Component) -> Component {
        component
    }
    
    public static func buildIf(_ component: Component?) -> Component {
        if let component = component {
            return component
        } else {
            return []
        }
    }
    
    public static func buildFinalResult(_ component: Component) -> [Constraint] {
        component.constraints
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        Array(components.map(\.constraints).joined())
    }
    
}

/**
 The product of a constraint DSL expression.
 
 Implement this type to make custom products of custom targets.
 */
public protocol LayoutComponent {
    
    var constraints: [Constraint] { get }
    
}

/**
 The "rhs" of a constraint assignment. The "second item" in NSLayoutConstraint parlence.
 */
public protocol ConstraintTarget {
    
    func apply(to constraint: inout ConstraintBuilder)
    
}

/**
 The "rhs" of a constraint assignment. The "second item" in NSLayoutConstraint parlence.
 */
public protocol ConstraintEdgesTarget {
    
    func apply(to edges: inout EdgesConstraintBuilder)
    
}

extension Int: ConstraintTarget, ConstraintEdgesTarget {
    
    public func apply(to constraint: inout ConstraintBuilder) {
        constraint.constant = CGFloat(self)
    }
    
    public func apply(to edges: inout EdgesConstraintBuilder) {
        edges.constant = CGFloat(self)
    }
    
}

extension Array: LayoutComponent where Element == Constraint {
    
    public var constraints: [Constraint] {
        self
    }
    
}
