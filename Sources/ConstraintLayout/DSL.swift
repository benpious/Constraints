import UIKit

@_functionBuilder
struct LayoutBuilder {
        
    typealias Component = LayoutComponent
    
    static func buildBlock(_ components: Component...) -> Component {
        Array(components.map(\.constraints).joined())
    }
    
    static func buildEither(first component: Component) -> Component {
        component
    }
    
    static func buildEither(second component: Component) -> Component {
        component
    }
    
    static func buildIf(_ component: Component?) -> Component {
        if let component = component {
            return component
        } else {
            return []
        }
    }
    
    static func buildFinalResult(_ component: Component) -> [Constraint] {
        component.constraints
    }
    
}

public protocol LayoutComponent {
    
    var constraints: [Constraint] { get }
    
}

public protocol ConstraintTarget {
    
    func apply(to constraint: inout ConstraintBuilder)
    
}

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
