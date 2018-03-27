//
//  Card.swift
//  Set2
//
//  Created by Vitalii Havryliuk on 12/17/17.
//  Copyright © 2017 Vitalii Havryliuk. All rights reserved.
//

import UIKit

struct SetCard: Equatable
{
    let numberOfSymbols: Variant
    let formOfSymbol: Variant
    let shadingOfSymbol: Variant
    let colorOfSymbol: Variant
    
    enum Variant: Int {
        case one = 1
        case two
        case three
        
        static var all: [Variant] { return [.one, .two, .three] }
    }
    
    static func ==(lhs: SetCard, rhs: SetCard) -> Bool {
        return (
            (lhs.numberOfSymbols == rhs.numberOfSymbols) &&
                (lhs.formOfSymbol == rhs.formOfSymbol) &&
                (lhs.shadingOfSymbol == rhs.shadingOfSymbol) &&
                (lhs.colorOfSymbol == rhs.colorOfSymbol)
        )
    }

    
}
