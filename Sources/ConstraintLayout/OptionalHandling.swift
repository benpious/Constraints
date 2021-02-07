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
