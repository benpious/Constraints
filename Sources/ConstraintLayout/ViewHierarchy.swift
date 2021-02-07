import UIKit

protocol ViewHierarchyComponent {
    
    var _views: [UIView] { get }
    
}

extension UIView: ViewHierarchyComponent {
    
    var _views: [UIView] {
        [self]
    }
    
}

extension Array: ViewHierarchyComponent where Element == UIView {
    
    var _views: [UIView] {
        self
    }
    
}

struct ViewHierarchy {
    
    init(@ViewHierarchyBuilder _ hierarchy: () -> (ViewHierarchy)) {
        self = hierarchy()
    }
    
    init(hierarchy: [UIView]) {
        self.hierarchy = hierarchy
    }
    
    var hierarchy: [UIView]
    
    func layout(@LayoutBuilder _ layout: ([UIView]) -> Layout) -> Layout {
        fatalError()
    }
    
}

@_functionBuilder
struct ViewHierarchyBuilder {
    
    typealias Component = ViewHierarchyComponent
    
    static func buildBlock(_ components: Component...) -> Component {
        Array(components.map(\._views).joined())
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
    
    static func buildFinalResult(_ component: Component) -> ViewHierarchy {
        ViewHierarchy(hierarchy: component._views)
    }

    
}
