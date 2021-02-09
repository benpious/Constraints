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
 Implement this protocol to use `ConstraintLayout`.
 
 ## Getting Started
 
 Here is a minimal implementation of `DeclarativeLayout`:
 
 ```
 class <#MyView#>: UIView, DeclarativeLayout {
 
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
        <#add views...#>
     } constraints: { <#views#> in
        <#constraints...#>
     }
 }
 
 @LayoutInput
 var <#Add any Inputs...#>

 }
 ```
 
 This example demonstrates the three things you need to know to get started
 with `ConstraintLayout`:
 
 - Constraints go in `layout`
 - You must call `prepareLayout()` for the layout code to actually be executed
 - Mutating `LayoutInputs` cause your `layout` to be re-evaluated
 
 ## Adding Views
 
 For safety, `ConstraintLayout` forces you to add views in a way that allows it to
 verify that the views are in the view hierarchy, _provided that you never mutate the
 `subviews` property of your view yourself_. To add views, you simply write them out in
 the order of the depth you want them to be shown:
 
 ```
 Layout {
    myChildView
    myOtherChildView
    if myLayoutInput {
        myThirdChildView
    }
 ...
 ```
 You can also use `if` statements with `else` to conditionally add views.
 
 ## Writing Constraints
 
 Once you've added the views, you can start writing constraints. Continuing the example
 from above, we might write a constraint block that looks like this:
 
 ```
 constraints: { myChildView, myOtherChildView, myThirdChildView in
    myChildView.leading.equalToSuperview().offset(10)
    myOtherChildView.edges.equalTo(myChildView)
    if let myThirdChildView = myThirdChildView.unwrapped {
        myThirdChildView.edges.equalToSuperview()
    }
    // and so on
 }
 ```
 
 Note that you can still access any property on the original views through
 `dynamicMemberLookup` if necessary. It's also important to note what you _cannot_ do:
 use any view that wasn't added in the view hierarchy step. And all views that might not
 be available are only available conditionally behind an `Optional`.
 */
public protocol DeclarativeLayout: UIView {
    
    /**
     The place where your layout is declared.
     
     See the documentation for `DeclarativeLayout` for more information on how to
     implement this function.
     */
    var layout: Layout { get }
    
}

extension InsertedView: ConstraintTarget, ConstraintEdgesTarget where T: AnyObject {
    
    public func apply(to edges: inout EdgesConstraintBuilder) {
        edges.second = .sibiling(wrapped)
    }
    
    public func apply(to constraint: inout ConstraintBuilder) {
        constraint.secondAttribute = constraint.firstAttribute
        constraint.second = .sibiling(wrapped)
    }

    public subscript<U>(dynamicMember member: KeyPath<T, U>) -> U {
        wrapped[keyPath: member]
    }

    /**
     Constrain the edges of the callee.
     */
    public var edges: EdgesAnchor {
        .init(base: wrapped)
    }
    
    /**
     Constrain the leading edge of the callee.
     */
    public var leading: LayoutAnchor {
        .init(base: wrapped,
              attribute: .leading)
    }
    
    /**
     Constrain the trailing edge of the callee.
     */
    public var trailing: LayoutAnchor {
        .init(base: wrapped,
              attribute: .trailing)
    }
    
    /**
     Constrain the top edge of the callee.
     */
    public var top: LayoutAnchor {
        .init(base: wrapped,
              attribute: .top)
    }
    
    /**
     Constrain the bottom edge of the callee.
     */
    public var bottom: LayoutAnchor {
        .init(base: wrapped,
              attribute: .bottom)
    }

    /**
     Constrain the width of the callee.
     */
    public var width: LayoutAnchor {
        .init(base: wrapped,
              attribute: .width)
    }
    
    /**
     Constrain the height of the callee.
     */
    public var height: LayoutAnchor {
        .init(base: wrapped,
              attribute: .height)
    }

}

public extension InsertedView where T: LayoutOptionalProtocol {
    
    /**
     Gets at the wrapped value so it can be read in an if-let in the DSL.
     */
    var unwrapped: InsertedView<T.Wrapped>? {
        if let wrapped = wrapped.___wrapped {
            return .init(wrapped)
        } else {
            return nil
        }
    }
    
}

public extension InsertedView where T: EitherProtocol {
    
    /**
     Gets at the true side of an if-else so it can be read in an if-let in the DSL.
     */
    var first: InsertedView<T.First>? {
        if let first = wrapped.first {
            return InsertedView<T.First>(first)
        } else {
            return nil
        }
    }
    
    /**
     Gets at the true side of an if-else so it can be read in an if-let in the DSL.
     */
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
        constraint.second = .sibiling(base)
        constraint.secondAttribute = attribute
    }
    
}
/**
 An object that, when not optional, is definitely a valid target for a constraint.
 */
@dynamicMemberLookup
public struct InsertedView<T> {
    
    init(_ wrapped: T) {
        self.wrapped = wrapped
    }
    
    let wrapped: T
        
    public struct LayoutAnchor {
                
        let base: T
        let attribute: Constraint.Attribute
        
        public var leading: EdgesAnchor {
            .init(base: base,
                  edges: [attribute, .leading])
        }
        
        public var trailing: EdgesAnchor {
            .init(base: base,
                  edges: [attribute, .trailing])
        }
        
        public var top: EdgesAnchor {
            .init(base: base,
                  edges: [attribute, .top])
        }

        public var bottom: EdgesAnchor {
            .init(base: base,
                  edges: [attribute, .bottom])
        }
        
        public func equalToSafeArea() -> ConstraintBuilder where T: UIView {
            var builder = ConstraintBuilder(first: base,
                                            firstAttribute: attribute,
                                            relationShip: .equalTo)
            builder.second = .safeArea(base)
            builder.secondAttribute = builder.firstAttribute
            return builder
        }

        
        public func equalToSuperview() -> ConstraintBuilder where T: UIView {
            var builder = ConstraintBuilder(first: base,
                                            firstAttribute: attribute,
                                            relationShip: .equalTo)
            builder.second = .superview(base)
            builder.secondAttribute = builder.firstAttribute
            return builder
        }
        
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
    
    public struct EdgesAnchor {
        
        init(base: T,
             edges: Set<Constraint.Attribute> = Constraint.Attribute.edges) {
            self.base = base
            self.edges = edges
        }
                
        let base: T
        let edges: Set<Constraint.Attribute>
        
        public var leading: EdgesAnchor {
            .init(base: base,
                  edges: edges.inserting(.leading))
        }
        
        public var trailing: EdgesAnchor {
            .init(base: base,
                  edges: edges.inserting(.trailing))
        }
        
        public var top: EdgesAnchor {
            .init(base: base,
                  edges: edges.inserting(.top))
        }
        
        public func equalToSafeArea() -> EdgesConstraintBuilder where T: UIView {
            var builder = EdgesConstraintBuilder(first: base,
                                                 relationShip: .equalTo,
                                                 attributes: edges)
            builder.second = .safeArea(base)
            return builder

        }
        
        public func equalToSuperview() -> EdgesConstraintBuilder where T: UIView {
            var builder = EdgesConstraintBuilder(first: base,
                                                 relationShip: .equalTo,
                                                 attributes: edges)
            builder.second = .superview(base)
            return builder
        }

        
        public func equalTo(_ layoutItem: ConstraintEdgesTarget) -> EdgesConstraintBuilder where T: AnyObject {
            var builder = EdgesConstraintBuilder(first: base,
                                                 relationShip: .equalTo,
                                                 attributes: edges)
            layoutItem.apply(to: &builder)
            return builder
        }
        
        public func greaterThan(_ layoutItem: ConstraintEdgesTarget) -> EdgesConstraintBuilder where T: AnyObject {
            var builder = EdgesConstraintBuilder(first: base,
                                                 relationShip: .greaterThan,
                                                 attributes: edges)
            layoutItem.apply(to: &builder)
            return builder
        }
        
        public func lessThan(_ layoutItem: ConstraintEdgesTarget) -> EdgesConstraintBuilder where T: AnyObject {
            var builder = EdgesConstraintBuilder(first: base,
                                                 relationShip: .greaterThan,
                                                 attributes: edges)
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
    
    /**
     Runs the layout, and establishes listeners for all `LayoutInput`s.
     
     Typically you should call this in your view's `init`.
     */
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
                return [:]
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
                return [:]
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

/**
 A layout, describing the view hierarchy and constraints of a view.
 */
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
                child.translatesAutoresizingMaskIntoConstraints = false
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
                newLayoutConstraint.isActive = true
                new[constraint.identifier] = newLayoutConstraint
            }
        }
        for unused in managedConstraints.values {
            unused.isActive = false
        }
        view._managedConstraints = new
    }
    
}

/**
 A constraint model.
 
 There is no need to interact with this type directly.
 */
public struct Constraint {
    
    init(
        first: AnyObject,
        firstAttribute: Constraint.Attribute,
        second: SecondItem?,
        secondAttribute: Constraint.Attribute,
        constant: CGFloat,
        multiple: CGFloat,
        relationShip: Constraint.Relation,
        priority: Float
    ) {
        var secondItemIdentifier: String {
            if let second = second {
                return second.description
            } else {
                return "nil"
            }
        }
        identifier = "\(ObjectIdentifier(first))\(secondItemIdentifier)\(firstAttribute)\(secondAttribute)\(multiple)\(priority)\(relationShip)"
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
        
        static var edges: Set<Self> {
            [
                .leading,
                .trailing,
                .top,
                .bottom
            ]
        }
        
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
    
    enum SecondItem: CustomStringConvertible {
        
        case superview(UIView)
        case safeArea(UIView)
        case sibiling(AnyObject)
        
        func object(in object: AnyObject) -> AnyObject? {
            switch self {
            case .superview:
                return object.superview
            case .sibiling(let object):
                return object
            case .safeArea(let object):
                if #available(iOS 11.0, *) {
                    return object.superview?.safeAreaLayoutGuide
                } else {
                    // TODO: set minimum deployment target to 11.0
                    assertionFailure("TODO: set minimum deployment target to 11.0")
                    return object.superview
                }
            }
        }
        
        var description: String {
            // TODO: this is a very hacky way of getting a string out of the
            // memory address
            switch self {
            case .superview(let view):
                return String(ObjectIdentifier(view).hashValue)
            case .safeArea(let view):
                return String(ObjectIdentifier(view).hashValue)
            case .sibiling(let sibiling):
            return String(ObjectIdentifier(sibiling).hashValue)
            }
        }
    }

    
    let identifier: String
    let first: AnyObject
    let firstAttribute: Attribute
    let second: SecondItem?
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
            toItem: second?.object(in: first) ?? nil,
            attribute: secondAttribute.asNSLayoutAttribute,
            multiplier: multiple,
            constant: constant
        )
    }
    
    func apply(to constraint: NSLayoutConstraint) {
        constraint.constant = constant
    }
    
}

fileprivate extension Set {
    
    func inserting(_ toInsert: Self.Element) -> Self {
        var new = self
        new.insert(toInsert)
        return new
    }
    
}
