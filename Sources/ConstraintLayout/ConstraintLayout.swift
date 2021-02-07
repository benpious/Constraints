import UIKit

public protocol DeclarativeLayout: UIView {
    
    var layout: Layout { get }
    
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
    
}

fileprivate var managedConstraintsKey = 0

fileprivate protocol LayoutInputting {
    
    var listener: DeclarativeLayout? { get set }
    
}

public struct Layout {
    
    let constraints: [Constraint]
    
    func apply(to view: DeclarativeLayout) {
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

public struct LayoutAnchor: LayoutItem {
    
    let view: UIView
    let attribute: Constraint.Attribute
    
    public func apply(to constraint: inout ConstraintBuilder) {
        constraint.second = view
        constraint.secondAttribute = attribute
    }
        
}

extension UIView: LayoutItem {
    
    public func apply(to constraint: inout ConstraintBuilder) {
        constraint.second = self
        constraint.secondAttribute = constraint.firstAttribute
    }
    
    var leading: LayoutAnchor {
        .init(view: self, attribute: .leading)
    }
    
    var trailing: LayoutAnchor {
        .init(view: self, attribute: .trailing)
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
        ViewHierarchy {
            UIView()
            if shouldAddLeading {
                UIView()
            }
        }
        .layout { hierarchy in
            
        }
    }
    
//    @LayoutBuilder
//    var layout: Layout {
//        if shouldAddLeading {
//            Leading.equalTo(UIView().leading).priority(1000).offset(10)
//        } else {
//            Leading.equalTo(UIView().leading).priority(1000).offset(10)
//        }
//        Trailing.equalTo(UIView().trailing)
//    }

    @LayoutInput
    var shouldAddLeading = false
}
