# ConstraintLayout

This library is still under construction. 

## What is ConstraintLayout?

`ConstraintLayout`  is a declarative autolayout library that prioritizes safety, clarity, and familiarity for users familiar with SwiftUI and layout anchors. It abstracts away state management and lets you write stateless constraints in the same way that you write stateless views in SwiftUI. 

The constraint API is heavily inspired by [SnapKit](https://github.com/SnapKit/SnapKit), though it leverages Swift Language features that were not available when that library was originally authored. 

## How is ConstraintLayout safer than raw Autolayout?

The biggest danger in autolayout is trying to add a constraint to a view that isn't in the view hierarchy. These bugs
are easy to write, espcially when dealing with state whose scope is beyond your view; keyboard notificatons 
are a great example of this phenomenon. 

`ConstraintLayout` makes autolayout safe by managing the view hierarchy for you, and ensuring at compile 
time that it is impossible to add a constriant to a view that isn't in the view hierarchy.

Of course, the above is only true if you never mutate the view heirarchy or create constraints yourself. 


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
the order of the depth you want them to be shown:

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
layout: { myChildView, myOtherChildView, myThirdChildView in
   myChildView.leading.equalToSuperview().offset(10)
   myOtherChildView.edges.equalTo(myChildView)
   if let myThirdChildView = myThirdChildView.unwrapped { // unfortunately it's necessary to have a little boilerplate here so we can use if-let.
       myThirdChildView.edges.equalToSuperview()
   }
   // and so on
}
```

Note that you can still access any property on the original views through
`dynamicMemberLookup` if necessary. It's also important to note what you _cannot_ do:
use any view that wasn't added in the view hierarchy step. And all views that might not
be available are only available conditionally behind an `Optional`.
