import UIKit

public protocol DeclarativeLayout: UIView {
    
    var layout: Layout { get }
    
}

extension InsertedView: ConstraintTarget where T: AnyObject {
    
    public func apply(to constraint: inout ConstraintBuilder) {
        constraint.second = wrapped
        constraint.secondAttribute = constraint.firstAttribute
    }

    subscript<U>(dynamicMember member: KeyPath<T, U>) -> U {
        wrapped[keyPath: member]
    }
    
    var leading: LayoutAnchor {
        .init(base: wrapped,
              attribute: .leading)
    }
    
    var trailing: LayoutAnchor {
        .init(base: wrapped,
              attribute: .trailing)
    }
    
    var top: LayoutAnchor {
        .init(base: wrapped,
              attribute: .top)
    }
    
    var bottom: LayoutAnchor {
        .init(base: wrapped,
              attribute: .bottom)
    }

    var width: LayoutAnchor {
        .init(base: wrapped,
              attribute: .width)
    }
    
    var height: LayoutAnchor {
        .init(base: wrapped,
              attribute: .height)
    }

}

public extension InsertedView where T: LayoutOptionalProtocol {
    
    var unwrapped: InsertedView<T.Wrapped>? {
        if let wrapped = wrapped.___wrapped {
            return .init(wrapped)
        } else {
            return nil
        }
    }
    
}

extension InsertedView where T: EitherProtocol {
    
    var first: InsertedView<T.First>? {
        if let first = wrapped.first {
            return InsertedView<T.First>(first)
        } else {
            return nil
        }
    }
    
    var second: InsertedView<T.Second>? {
        if let second: T.Second = wrapped.second {
            return InsertedView<T.Second>(second)
        } else {
            return nil
        }
    }

    
}

extension InsertedView.LayoutAnchor: ConstraintTarget where T: AnyObject {
    
    public func apply(to constraint: inout ConstraintBuilder) {
        constraint.second = base
        constraint.secondAttribute = attribute
    }
    
}

@dynamicMemberLookup
public struct InsertedView<T> {
    
    init(_ wrapped: T) {
        self.wrapped = wrapped
    }
    
    let wrapped: T
        
    public struct LayoutAnchor {
                
        let base: AnyObject
        let attribute: Constraint.Attribute
        
        public func equalTo(_ layoutItem: ConstraintTarget) -> ConstraintBuilder where T: AnyObject {
            var builder = ConstraintBuilder(first: base,
                                            firstAttribute: attribute,
                                            relationShip: .equalTo)
            layoutItem.apply(to: &builder)
            return builder
        }
        
        public func greaterThan(_ layoutItem: ConstraintTarget) -> ConstraintBuilder where T: AnyObject {
            var builder = ConstraintBuilder(first: base,
                                            firstAttribute: attribute,
                                            relationShip: .greaterThan)
            layoutItem.apply(to: &builder)
            return builder
        }
        
        public func lessThan(_ layoutItem: ConstraintTarget) -> ConstraintBuilder where T: AnyObject {
            var builder = ConstraintBuilder(first: base,
                                            firstAttribute: attribute,
                                            relationShip: .greaterThan)
            layoutItem.apply(to: &builder)
            return builder
        }

    }
    
}

@propertyWrapper
public final class LayoutInput<T>: LayoutInputting {
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    fileprivate unowned var listener: DeclarativeLayout?
    
    public var wrappedValue: T {
        didSet {
            listener?._layoutInputDidChange()
        }
    }
    
}

extension DeclarativeLayout {
    
    public func prepareLayout() {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if var value = child.value as? LayoutInputting {
                value.listener = self
            }
        }
        layout.apply(to: self)
    }
    
    func _layoutInputDidChange() {
        layout.apply(to: self)
    }
        
    var _managedConstraints: [String: NSLayoutConstraint] {
        get {
            let associatedObject = objc_getAssociatedObject(self, &managedConstraintsKey)
            if let managedConstraints = associatedObject as? [String: NSLayoutConstraint] {
                return managedConstraints
            } else {
                fatalError("Found object of type \(type(of: associatedObject)), but expected object of type [String: NSLayoutConstraint].")
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &managedConstraintsKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC
            )
        }
    }
    
    var _managedViews: [ObjectIdentifier: UIView] {
        get {
            let associatedObject = objc_getAssociatedObject(self, &managedViewsKey)
            if let managedViews = associatedObject as? [ObjectIdentifier: UIView] {
                return managedViews
            } else {
                fatalError("Found object of type \(type(of: associatedObject)), but expected object of type [String: NSLayoutConstraint].")
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &managedViewsKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC
            )
        }
    }

    
}

fileprivate var managedConstraintsKey = 0
fileprivate var managedViewsKey = 0

fileprivate protocol LayoutInputting {
    
    var listener: DeclarativeLayout? { get set }
    
}

public struct Layout {
    
    let constraints: [Constraint]
    let views: [UIView]
    
    func apply(to view: DeclarativeLayout) {
        var newManagedViews: [ObjectIdentifier: UIView] = [:]
        var oldManagedViews = view._managedViews
        for (index, child) in views.enumerated() {
            let identifier = ObjectIdentifier(child)
            oldManagedViews[identifier] = nil
            newManagedViews[identifier] = child
            if let oldIndex = view.subviews.firstIndex(of: child) {
                if index != oldIndex {
                    // TODO: does this cause constraints to be removed?
                    view.insertSubview(child,
                                       at: index)
                }
            } else {
                view.insertSubview(child,
                                   at: index)
            }
        }
        for view in oldManagedViews.values {
            view.removeFromSuperview()
        }
        view._managedViews = newManagedViews
        var managedConstraints = view._managedConstraints
        var new: [String: NSLayoutConstraint] = [:]
        for constraint in constraints {
            if let existing = managedConstraints[constraint.identifier] {
                managedConstraints[constraint.identifier] = nil
                constraint.apply(to: existing)
                new[constraint.identifier] = existing
            } else {
                let newLayoutConstraint = constraint.makeConstraint()
                new[constraint.identifier] = newLayoutConstraint
            }
        }
        for unused in managedConstraints.values {
            unused.isActive = false
        }
        view._managedConstraints = new
    }
    
}

public struct Constraint {
    
    init(
        first: AnyObject,
        firstAttribute: Constraint.Attribute,
        second: AnyObject?,
        secondAttribute: Constraint.Attribute,
        constant: CGFloat,
        multiple: CGFloat,
        relationShip: Constraint.Relation,
        priority: Float
    ) {
        var identifierForSecondItem: String {
            second
                .map(ObjectIdentifier.init)
                .map(String.init(describing: )) ?? "nil"
        }
        identifier = "\(ObjectIdentifier(first))\(identifierForSecondItem)\(firstAttribute)\(secondAttribute)\(multiple)\(priority)"
        self.first = first
        self.firstAttribute = firstAttribute
        self.second = second
        self.secondAttribute = secondAttribute
        self.constant = constant
        self.multiple = multiple
        self.relationShip = relationShip
        self.priority = priority
    }
    
            
    enum Relation: Hashable {
        
        case equalTo
        case greaterThan
        case lessThan
        
        var asNSLayoutRelation: NSLayoutConstraint.Relation {
            switch self {
            case .greaterThan:
                return .greaterThanOrEqual
            case .equalTo:
                return .equal
            case .lessThan:
                return .lessThanOrEqual
            }
        }
        
    }
    
    
    enum Attribute: Hashable {
        
        case leading
        case trailing
        case height
        case width
        case top
        case bottom
        case noAttribute
        case centerX
        case centerY
        
        var asNSLayoutAttribute: NSLayoutConstraint.Attribute {
            switch self {
            case .bottom:
                return .bottom
            case .leading:
                return .leading
            case .top:
                return .top
            case .trailing:
                return .trailing
            case .height:
                return .height
            case .width:
                return .width
            case .noAttribute:
                return .notAnAttribute
            case .centerX:
                return .centerX
            case .centerY:
                return .centerY
            }
        }
        
    }
    
    let identifier: String
    let first: AnyObject
    let firstAttribute: Attribute
    let second: AnyObject?
    let secondAttribute: Attribute
    let constant: CGFloat
    let multiple: CGFloat
    let relationShip: Relation
    let priority: Float
            
    func makeConstraint() -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: first,
            attribute: firstAttribute.asNSLayoutAttribute,
            relatedBy: relationShip.asNSLayoutRelation,
            toItem: second,
            attribute: secondAttribute.asNSLayoutAttribute,
            multiplier: multiple,
            constant: constant
        )
    }
    
    func apply(to constraint: NSLayoutConstraint) {
        constraint.constant = constant
    }
    
}


// Test code:

class View: UIView, DeclarativeLayout {
    
    init() {
        super.init(frame: .zero)
        prepareLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var layout: Layout {
        Layout {
            UIView()
            if shouldAddLeading {
                UIView()
            } else {
                UIView()
            }
        } constraints: { (a, b) in
            if let b = b.first, shouldAddLeading {
                a.leading.equalTo(b.trailing)
                a.width.equalTo(7)
            }
        }
    }
    
    @LayoutInput
    var shouldAddLeading = false
}
