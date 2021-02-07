//
//  File.swift
//  
//
//  Created by Benjamin Pious on 2/7/21.
//

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
            return EmptyComponent()
        }
    }
    
    static func buildFinalResult(_ component: Component) -> [Constraint] {
        component.constraints
    }
    
}

class EmptyComponent: LayoutComponent {
    
    let constraints: [Constraint] = []
    
}

public protocol LayoutComponent {
    
    var constraints: [Constraint] { get }
    
}

public protocol LayoutItem {
    
    func apply(to constraint: inout ConstraintBuilder)
    
}

extension Array: LayoutComponent where Element == Constraint {
    
    public var constraints: [Constraint] {
        self
    }
    
}
