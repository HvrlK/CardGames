//
//  SetDeck.swift
//  Set2
//
//  Created by Vitalii Havryliuk on 12/17/17.
//  Copyright © 2017 Vitalii Havryliuk. All rights reserved.
//

import Foundation
import GameplayKit.GKRandomSource

class SetGame
{
    //MATK: properties
    
    private(set) var deck = [SetCard]()
    private(set) var cardsInGame = [SetCard]()
    private(set) var selectedCards = [SetCard]()
    private(set) var hintIndex = [Int]()
    private(set) var matching = false
    private(set) var score = 0
    private(set) var time = Date()
    
    //MARK: public functions
    
    init() {
        initDeck()
        draw(GameConstant.numberOfInitialCards)
    }
    
    func selectCard(at index: Int) {
        matching = false
        
        if (index >= 0 && index < cardsInGame.count) {
            let card = cardsInGame[index]
            
            if selectedCards.count < GameConstant.numberOfCardsPerSet {
                if let selectedCardIndex = selectedCards.index(of: card) {
                    selectedCards.remove(at: selectedCardIndex)
                    score += GameConstant.deselectPenalty
                } else {
                    selectedCards.append(card)
                }
            } else {
                selectedCards.removeAll()
                selectedCards.append(card)
            }
            
            if selectedCards.count == GameConstant.numberOfCardsPerSet {
                if isSet(cards: selectedCards) {
                    matching = true
                    score = -time.timeIntervalSinceNow < 30.0 ? score + GameConstant.matchedSetPoints + Int(time.timeIntervalSinceNow / 10) : score + 1
                    time = Date()
                } else {
                    score += GameConstant.incorrectSetPenalty
                }
            }
        }
    }
    
    func dealtCards()  {
        if matching {
            for card in selectedCards {
                if let index = cardsInGame.index(of: card) {
                    cardsInGame.remove(at: index)
                    if !deck.isEmpty {
                        cardsInGame.insert(deck.popLast()!, at: index)
                    }
                }
            }
        } else {
            score = hint() == true ? score + GameConstant.dealCardsPenalty : score
            draw(GameConstant.numberOfCardsPerDeal)
        }
        matching = false
    }
    
    func hint() -> Bool {
        hintIndex.removeAll()
        for firstIndex in 0..<cardsInGame.count {
            for secondIndex in firstIndex + 1..<cardsInGame.count {
                for thirdIndex in secondIndex + 1..<cardsInGame.count {
                    if isSet(cards: [cardsInGame[firstIndex], cardsInGame[secondIndex], cardsInGame[thirdIndex]]) {
                        hintIndex.append(firstIndex)
                        hintIndex.append(secondIndex)
                        hintIndex.append(thirdIndex)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func hintSet() {
        selectedCards.removeAll()
        for index in hintIndex.indices {
            selectCard(at: hintIndex[index])
        }
        matching = true
    }
    
    func canDealMoreCards() -> Bool {
        return deck.count >= GameConstant.numberOfCardsPerDeal || matching == true
    }
    
    func canHint() -> Bool {
        return hint() && !matching
    }
    
    func reset() {
        deck.removeAll()
        cardsInGame.removeAll()
        selectedCards.removeAll()
        matching = false
        score = 0
        time = Date()
        initDeck()
        draw(GameConstant.numberOfInitialCards)
    }
    
    func shuffleCardsInGame() {
        cardsInGame = shuffle(cardsInGame)
    }
    
    //MARK: privat functions
    
    private func initDeck() {
        for number in SetCard.Variant.all {
            for color in SetCard.Variant.all {
                for form in SetCard.Variant.all {
                    for shading in SetCard.Variant.all {
                        deck.append(SetCard(numberOfSymbols: number, formOfSymbol: form, shadingOfSymbol: shading, colorOfSymbol: color))
                    }
                }
            }
        }
        
        deck = shuffle(deck)
    }
    
    private func shuffle(_ cards: [SetCard]) -> [SetCard] {
        return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: cards) as! [SetCard]
    }
    
    private func draw(_ numberOfCards: Int) {
        if deck.count >= numberOfCards {
            for _ in 0..<numberOfCards {
                if let drawnCard = deck.popLast() {
                    cardsInGame.append(drawnCard)
                }
            }
        }
    }
    
    private func isSet(cards: [SetCard]) -> Bool {
        let sum = [
            cards.reduce(0, { $0 + $1.numberOfSymbols.rawValue}),
            cards.reduce(0, { $0 + $1.colorOfSymbol.rawValue}),
            cards.reduce(0, { $0 + $1.formOfSymbol.rawValue}),
            cards.reduce(0, { $0 + $1.shadingOfSymbol.rawValue})
        ]
        return sum.reduce(true, { $0 && ($1 % 3 == 0) })
    }
    
}

extension SetGame {
    private struct GameConstant {
        static let numberOfInitialCards: Int = 12
        static let numberOfCardsPerDeal: Int = 3
        static let numberOfCardsPerSet: Int = 3
        
        static let dealCardsPenalty: Int = -2
        static let incorrectSetPenalty: Int = -5
        static let matchedSetPoints: Int = 4
        static let deselectPenalty: Int = -1
    }
}

