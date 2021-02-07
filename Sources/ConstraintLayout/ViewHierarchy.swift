import UIKit

protocol ViewHierarchyComponent {
    
}

extension UIView: ViewHierarchyComponent {
    
}

protocol LayoutWrapper {
    
    associatedtype Interface
    
    var interface: Interface { get }
    
}

struct ViewWrapper<T>: LayoutWrapper where T: AnyObject {
    
    init(_ wrapped: T) {
        self.wrapped = wrapped
    }
    
    let wrapped: T
    
    var interface: ViewLayoutWrapper<T> {
            fatalError()
        }
    
}

struct OptionalViewWrapper<T>: LayoutWrapper where T: AnyObject {
    
    let wrapped: T?
    
    init(_ wrapped: T?) {
        self.wrapped = wrapped
    }
    
    var interface: ViewLayoutWrapper<T>? {
            fatalError()
        }
    
}

struct ViewHierarchy1<A> where A: LayoutWrapper {
     
    init(@ViewHierarchyBuilder _ hierarchy: () -> (ViewHierarchy1)) {
        self = hierarchy()
    }
    
    init(a: A) {
        self.a = a
    }
    
    var a: A
    
    func layout(@LayoutBuilder _ layout: (A.Interface) -> Layout) -> Layout {
        fatalError()
    }
    
}

struct ViewHierarchy2<A, B> where A: LayoutWrapper, B: LayoutWrapper {
     
    init(@ViewHierarchyBuilder _ hierarchy: () -> (ViewHierarchy2)) {
        self = hierarchy()
    }
    
    init(a: A, b: B) {
        self.a = a
        self.b = b
    }
    
    var a: A
    var b: B
    
    func layout(@LayoutBuilder _ layout: (A.Interface, B.Interface) -> Layout) -> Layout {
        fatalError()
    }
    
}

extension Optional: ViewHierarchyComponent where Wrapped: ViewHierarchyComponent {
    
}

@_functionBuilder
struct ViewHierarchyBuilder {
    
    typealias Component = ViewHierarchyComponent
    
    static func buildBlock<A>(_ a: A) -> ViewHierarchy1<ViewWrapper<A>> where A: Component {
        .init(a: ViewWrapper(a))
    }
    
    static func buildBlock<A, B>(_ a: A, _ b: B) -> ViewHierarchy2<ViewWrapper<A>, ViewWrapper<B>> where A: Component, B: Component {
        .init(a: ViewWrapper(a), b: ViewWrapper(b))
    }
    
    static func buildBlock<A, B>(_ a: A, _ b: OptionalViewWrapper<B>) -> ViewHierarchy2<ViewWrapper<A>, OptionalViewWrapper<B>> where A: Component, B: Component {
        .init(a: ViewWrapper(a), b: b)
    }

    
    static func buildIf<A>(_ component: ViewHierarchy1<ViewWrapper<A>>?) -> OptionalViewWrapper<A> where A: ViewHierarchyComponent {
        if let component = component {
            return OptionalViewWrapper(component.a.wrapped)
        } else {
            fatalError()
        }
    }
    
}

//    static func buildBlock<A, B, C>(_ a: A, _ b: B, _ c: C) -> ViewHierarchy3<A, B, C> where A: Component, B: Component, C: Component {
//        .init(a: a, b: b, c: c)
//    }
//
//
//    static func buildEither<A, B>(first component: A) -> Either<A, B> where A: Component, B: Component {
//        Either(first: component)
//    }
    
//    static func buildEither<A, B>(second component: B) -> Either<A, B> where A: Component, B: Component {
//        Either(second: component)
//    }

//struct Either<First, Second>: ViewHierarchyComponent where First: ViewHierarchyComponent, Second: ViewHierarchyComponent {
//
//    var first: First? = nil
//    var second: Second? = nil
//
//}
//
//struct ViewHierarchy3<A, B, C> where A: LayoutWrapper, B: LayoutWrapper, C: LayoutWrapper {
//
//    init(@ViewHierarchyBuilder _ hierarchy: () -> (ViewHierarchy3<A, B, C>)) {
//        self = hierarchy()
//    }
//
//    init(a: A, b: B, c: C) {
//        self.a = a
//        self.b = b
//        self.c = c
//    }
//
//    var a: A
//    var b: B
//    var c: C
//
//    func layout(@LayoutBuilder _ layout: (A.Interface, B.Interface, C.Interface) -> Layout) -> Layout {
//        fatalError()
//    }
//
//}
