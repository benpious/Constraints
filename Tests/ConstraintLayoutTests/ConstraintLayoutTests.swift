import XCTest
import UIKit

@testable import ConstraintLayout

final class ConstraintLayoutTests: XCTestCase {
    
    func testExample() {
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

class C: UIView, DeclarativeLayout {
    
    let layout: Layout = Layout(constraints: [])
    
    @LayoutInput
    var a: Bool = false
    
}
