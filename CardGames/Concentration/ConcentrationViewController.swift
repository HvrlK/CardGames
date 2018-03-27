//
//  ViewController.swift
//  Concentration
//
//  Created by Vitalii Havryliuk on 12/13/17.
//  Copyright © 2017 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController
{
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairsOfCard)
    
    var numberOfPairsOfCard: Int {
            return (cardButtons.count + 1) / 2
    }
    
    private(set) var flipCount = 0 {
        didSet {
            updateFlipCountLabel()
        }
    }
    
    private func updateFlipCountLabel() {
        let attributes: [NSAttributedStringKey:Any] = [
            .strokeWidth : 5.0,
            .strokeColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        ]
        let attributedString = NSAttributedString(string: "Flips: \(flipCount)", attributes: attributes)
        flipCountLabel.attributedText = attributedString
    }
    
    var scoreCount = 0 {
        didSet {
            updateScoreCountLabel()
        }
    }
    
    private func updateScoreCountLabel() {
        let attributes: [NSAttributedStringKey:Any] = [
            .strokeWidth : 5.0,
            .strokeColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        ]
        let attributedString = NSAttributedString(string: "Score: \(scoreCount) /  ", attributes: attributes)
        scoreCountLabel.attributedText = attributedString
    }
    
    @IBOutlet private weak var flipCountLabel: UILabel! {
        didSet {
            updateFlipCountLabel()
        }
    }
    
    @IBOutlet private weak var scoreCountLabel: UILabel! {
        didSet {
            updateScoreCountLabel()
        }
    }
    
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBAction private func touchCard(_ sender: UIButton) {
        flipCount += 1
        if let cardNumber = cardButtons.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
            updateScore()
        } else {
            print("chosen card is not in cardButtons")
        }
    }
    
    @IBAction private func newGame(_ sender: UIButton) {
        game = Concentration(numberOfPairsOfCards: numberOfPairsOfCard)
        emojiChoices = theme ?? "🐶🐱🐭🏐🎱😍😎🤓"
        indexMatched = Set<Int>()
        indexNotMatched = Set<Int>()
        flipCount = 0
        scoreCount = 0
        numberOfTouchCard = 0
        updateViewFromModel()
    }
    
   
    private func updateViewFromModel() {
        if cardButtons != nil {
            for index in cardButtons.indices {
                let button = cardButtons[index]
                let card = game.cards[index]
                if card.isFaceUp {
                    button.setTitle(emoji(for: card), for: UIControlState.normal)
                    button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                } else {
                    button.setTitle("", for: UIControlState.normal)
                    button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                }
            }
        }
    }
    
    var theme: String? {
        didSet {
            emojiChoices = theme ?? ""
            emoji = [:]
            updateViewFromModel()
        }
    }
    
    private lazy var emojiChoices = "🐶🐱🐭🏐🎱😍😎🤓"

    private var emoji = [Card:String]()
    
    private func emoji(for card: Card) -> String {
        if emoji[card] == nil, emojiChoices.count > 0 {
            let randomStringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: emojiChoices.count.arc4random)
            emoji[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
        return emoji[card] ?? "?"
    }
     
    private var indexMatched = Set<Int>()
    
    private var indexNotMatched = Set<Int>()
    
    private var numberOfTouchCard = 0
    
    private func updateScore() {
        numberOfTouchCard += 1
        if numberOfTouchCard == 2 {
            for index in game.cards.indices {
                let card = game.cards[index]
                if card.isFaceUp {
                    if card.isMatched, !indexMatched.contains(index) {
                        scoreCount += 1
                        indexMatched.insert(index)
                    }
                    if !card.isMatched, indexNotMatched.contains(index) {
                        scoreCount -= 1
                    }
                    if !card.isMatched, !indexNotMatched.contains(index) {
                        indexNotMatched.insert(index)
                    }
                }
                indexNotMatched = indexNotMatched.subtracting(indexMatched)
            }
            numberOfTouchCard = 0
        }
    }
}



extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}








