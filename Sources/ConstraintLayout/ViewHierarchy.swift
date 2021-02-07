import UIKit

public protocol ViewHierarchyComponent {
    
}

extension UIView: ViewHierarchyComponent {
    
}

extension Layout {
    
    public init<A>(
        @ViewHierarchyBuilder viewHierarchy: () -> (ViewHierarchy1<A>),
        @LayoutBuilder constraints: (InsertedView<A>) -> [Constraint]
    ) {
        let viewHierarchy = viewHierarchy()
        self = .init(
            constraints: viewHierarchy.layout(constraints),
            views: viewHierarchy.views
        )
    }
    
    public init<A, B>(
        @ViewHierarchyBuilder viewHierarchy: () -> (ViewHierarchy2<A, B>),
        @LayoutBuilder constraints: (InsertedView<A>, InsertedView<B>) -> [Constraint]
    ) {
        let viewHierarchy = viewHierarchy()
        self = .init(
            constraints: viewHierarchy.layout(constraints),
            views: viewHierarchy.views
        )
    }
    
    public init<A, B, C>(
        @ViewHierarchyBuilder viewHierarchy: () -> (ViewHierarchy3<A, B, C>),
        @LayoutBuilder constraints: (InsertedView<A>, InsertedView<B>, InsertedView<C>) -> [Constraint]
    ) {
        let viewHierarchy = viewHierarchy()
        self = .init(
            constraints: viewHierarchy.layout(constraints),
            views: viewHierarchy.views
        )
    }

    
    
}

public struct ViewHierarchy1<A> {
    
    init(@ViewHierarchyBuilder _ hierarchy: () -> (ViewHierarchy1)) {
        self = hierarchy()
    }
    
    init(a: A) {
        self.a = a
    }
    
    var a: A
    
    func layout(@LayoutBuilder _ layout: (InsertedView<A>) -> [Constraint]) -> [Constraint] {
        layout(InsertedView(a))
    }
    
    var views: [UIView] {
        [a].compactMap { $0 as? UIView }
    }
    
}

public struct ViewHierarchy2<A, B> {
    
    init(@ViewHierarchyBuilder _ hierarchy: () -> (ViewHierarchy2)) {
        self = hierarchy()
    }
    
    public init(a: A, b: B) {
        self.a = a
        self.b = b
    }
    
    var a: A
    var b: B
    
    func layout(@LayoutBuilder _ layout: (InsertedView<A>, InsertedView<B>) -> [Constraint]) -> [Constraint] {
        layout(InsertedView(a), InsertedView(b))
    }
    
    var views: [UIView] {
        [a, b].compactMap { $0 as? UIView }
    }
    
}

public struct ViewHierarchy3<A, B, C> {
    
    init(@ViewHierarchyBuilder _ hierarchy: () -> (ViewHierarchy3)) {
        self = hierarchy()
    }
    
    public init(a: A, b: B, c: C) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    var a: A
    var b: B
    var c: C
    
    func layout(@LayoutBuilder _ layout: (InsertedView<A>, InsertedView<B>, InsertedView<C>) -> [Constraint]) -> [Constraint] {
        layout(InsertedView(a), InsertedView(b), InsertedView(c))
    }
    
    var views: [UIView] {
        [a, b, c].compactMap { $0 as? UIView }
    }
    
}


extension Optional: ViewHierarchyComponent where Wrapped: ViewHierarchyComponent {
    
}

@_functionBuilder
public struct ViewHierarchyBuilder {
    
    public typealias Component = ViewHierarchyComponent
    
    public static func buildBlock<A>(_ a: A) -> A where A: Component {
        a
    }
    
    public static func buildBlock<A>(_ a: A) -> ViewHierarchy1<A> where A: Component {
        .init(a: a)
    }
    
    public static func buildBlock<A, B>(_ a: A, _ b: B) -> ViewHierarchy2<A, B> where A: Component, B: Component {
        .init(a: a, b: b)
    }
    
    public static func buildBlock<A, B, C>(_ a: A, _ b: B, _ c: C) -> ViewHierarchy3<A, B, C> where A: Component, B: Component, C: Component {
        .init(a: a, b: b, c: c)
    }

    
    public static func buildEither<A, B>(first component: A) -> Either<A, B> where A: Component, B: Component {
        Either(first: component)
    }
    
    public static func buildEither<A, B>(second component: B) -> Either<A, B> where A: Component, B: Component {
        Either(second: component)
    }
    
    public static func buildIf<A>(_ component: ViewHierarchy1<A>?) -> A? where A: Component {
        if let component = component {
            return component.a
        } else {
            return nil
        }
    }
    
}

public protocol EitherProtocol {
    
    associatedtype First
    associatedtype Second
    
    var first: First? { get }
    var second: Second? { get }
}

public struct Either<First, Second>: EitherProtocol, ViewHierarchyComponent where First: ViewHierarchyComponent, Second: ViewHierarchyComponent {
    
    public var first: First? = nil
    public var second: Second? = nil
    
}

