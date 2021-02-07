/*
 An Implementation detail of `ConstraintLayout`. You shouldn't need to interact with this directly.
 */
public protocol LayoutOptionalProtocol {
    
    associatedtype Wrapped
    
    var ___wrapped: Wrapped? { get }
    
}

extension Optional: LayoutOptionalProtocol {
    
    /*
     An Implementation detail of `ConstraintLayout`. You shouldn't need to interact with this directly.
     */
    public var ___wrapped: Wrapped? {
        self
    }
    
}
