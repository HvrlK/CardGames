//
//  Concentration.swift
//  Concentration
//
//  Created by Vitalii Havryliuk on 12/13/17.
//  Copyright © 2017 Vitalii Havryliuk. All rights reserved.
//

import Foundation

struct Concentration
{
    private(set) var cards = [Card]()
    
    private var indexOfOneAndFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set{
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index )): chosen index not in the cards")
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndFaceUpCard, matchIndex != index {
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                }
                cards[index].isFaceUp = true
             } else { 
                indexOfOneAndFaceUpCard = index
            }
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(at: \(numberOfPairsOfCards)): you must have at least one pair of cards")
        for _ in 0..<numberOfPairsOfCards
        {
            let card = Card()
            cards += [card, card]
        }
        var randomCards = cards
        for index in 0..<cards.count
        {
            for _ in 0..<cards.count {
                let randomIndex = 50.arc4random % cards.count
                swap(&cards[index], &randomCards[randomIndex])
                swap(&cards[randomIndex], &randomCards[index])
            }
        }
    }
}


extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}



















