//
//  ViewController.swift
//  Set2
//
//  Created by Vitalii Havryliuk on 3/1/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController {
    
    // MARK: properties
    
    private var setGame = SetGame()
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    // MARK: outlets
    
    @IBOutlet private var scoreLabel: UILabel!
    
    @IBOutlet private var dealtButton: UIButton!
    @IBOutlet private var newGameButton: UIButton!
    @IBOutlet private var hintButton: UIButton!
    @IBOutlet weak var startGameLabel: UILabel!
    
    @IBOutlet private var boardView: BoardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(dealt(_:)))
            swipe.direction = .down
            boardView.addGestureRecognizer(swipe)
            let rotate = UIRotationGestureRecognizer(target: self,
                                                     action: #selector(reshuffle(_:)))
            boardView.addGestureRecognizer(rotate)
        }
    }
    
    // MARK: actions
    
    @IBAction func dealtCards(_ sender: UIButton) {
        setGame.dealtCards()
        updateViewFromModel()
        layingOutAnimation()
    }
    
    @objc func dealt(_ sender: UITapGestureRecognizer) {
        if dealtButton.isUserInteractionEnabled {
            setGame.dealtCards()
            updateViewFromModel()
            layingOutAnimation()
        }
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        if !startGameLabel.isHidden {
            startGame()
        }
        dealtButton.isHidden = false
        boardView.cardViews.removeAll()
        setGame.reset()
        updateViewFromModel()
        layingOutAnimation()
    }
    
    @IBAction func hint(_ sender: UIButton) {
        if setGame.hint() {
            setGame.hintSet()
        }
        flyAway()
    }
    
    // MARK: public functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dealtButton.alpha = 0
        hintButton.alpha = 0
    }
    
    
    // MARK: private functions
    
    @objc
    private func tapCard(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let cardView = recognizer.view! as? SetCardView {
                setGame.selectCard(at: boardView.cardViews.index(of: cardView)!)
            }
            updateViewFromModel()
            flyAway()
        default:
            break
        }
    }
    
    @objc
    private func reshuffle(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            setGame.shuffleCardsInGame()
            updateViewFromModel()
        default:
            break
        }
    }
    
    private func startGame() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1,
            delay: 0,
            options: [],
            animations: {
                self.dealtButton.alpha = 1
                self.hintButton.alpha = 1
                self.startGameLabel.alpha = 0
        },
            completion: {_ in
                self.startGameLabel.isHidden = true
        })
    }
    
    private func updateViewFromModel() {
        dealtButton.isEnabled = setGame.canDealMoreCards()
        hintButton.isEnabled = setGame.canHint()
        updateCardViewsFromModel()
        scoreLabel.text = "Score: \(setGame.score)"
        updateBorders()
    }
    
    private func updateCardViewsFromModel() {
        if boardView.cardViews.count - setGame.cardsInGame.count > 0 {
            for index in setGame.selectedCards.indices {
                let card = setGame.selectedCards[index]
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.3,
                    delay: 1,
                    options: [],
                    animations: {
                        self.boardView.cardViews.forEach {
                            if $0.colorOfSymbol == card.colorOfSymbol.rawValue && $0.numberOfSymbols == card.numberOfSymbols.rawValue && $0.shadingOfSymbol == card.shadingOfSymbol.rawValue && $0.formOfSymbol == card.formOfSymbol.rawValue {
                                self.boardView.cardViews.remove(at: self.boardView.cardViews.index(of: $0)!)
                            }
                            
                        }
                }, completion: nil)
            }
        } else {
            let numberCardViews = boardView.cardViews.count
            for index in setGame.cardsInGame.indices {
                let card = setGame.cardsInGame[index]
                if index > (numberCardViews - 1) {
                    let cardView = SetCardView()
                    cardView.isFaceUp = false
                    cardView.isHidden = true
                    updateCardView(cardView, for: card)
                    addTapGestureRecognizer(for: cardView)
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.3,
                        delay: 0,
                        options: [],
                        animations: {
                            self.boardView.cardViews.append(cardView)
                    }, completion: { _ in
                        cardView.isHidden = false
                    })
                } else {
                    let cardView = boardView.cardViews[index]
                    updateCardView(cardView, for: card)
                }
            }
        }
    }
    
    private func updateCardView(_ cardView: SetCardView, for card: SetCard) {
        cardView.isUserInteractionEnabled = setGame.matching ? false : true
        cardView.colorOfSymbol = card.colorOfSymbol.rawValue
        cardView.numberOfSymbols = card.numberOfSymbols.rawValue
        cardView.shadingOfSymbol = card.shadingOfSymbol.rawValue
        cardView.formOfSymbol = card.formOfSymbol.rawValue
    }
    
    private func updateBorders() {
        let selectCards = setGame.selectedCards
        let cardsInGame = setGame.cardsInGame
        for index in cardsInGame.indices {
            let card = cardsInGame[index]
            let cardView = boardView.cardViews[index]
            cardView.layer.borderWidth = cardView.frame.size.width * 0.03
            cardView.layer.borderColor = UIColor.clear.cgColor
            if selectCards.contains(card) {
                if selectCards.count < 3 {
                    cardView.layer.borderColor = #colorLiteral(red: 0.9258407361, green: 0.8299284639, blue: 0.2816037281, alpha: 1)
                } else {
                    cardView.layer.borderColor = !setGame.matching ? #colorLiteral(red: 0.9845732868, green: 0.4010361191, blue: 0.3556970509, alpha: 1) : UIColor.clear.cgColor
                }
            }
        }
    }
    
    private func addTapGestureRecognizer(for cardView: SetCardView) {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapCard(recognizedBy: )))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tap)
    }
    
    private func flyAway() {
        if setGame.selectedCards.count == 3, setGame.matching {
            for index in self.setGame.cardsInGame.indices {
                let card = self.setGame.cardsInGame[index]
                let cardView = self.boardView.cardViews[index]
                if self.setGame.selectedCards.contains(card) {
                    cardView.isFaceUp = dealtButton.isHidden ? true : false
                    let tempCardView = SetCardView()
                    view.insertSubview(tempCardView, aboveSubview: boardView)
                    updateCardView(tempCardView, for: card)
                    tempCardView.isFaceUp = true
                    tempCardView.frame = cardView.frame
                    cardBehavior.addItem(tempCardView)
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.7,
                        delay: 0,
                        options: [],
                        animations: {
                            tempCardView.frame.size = CGSize(width: 1.5 * tempCardView.frame.size.width, height: 1.5 * tempCardView.frame.size.height)
                    },
                        completion: { (_) in
                            self.cardBehavior.removeItem(tempCardView)
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.7,
                                delay: 0,
                                options: [],
                                animations: {
                                    tempCardView.frame = self.hintButton.frame
                            }, completion: { position in
                                UIView.transition(
                                    with: tempCardView,
                                    duration: 0.5,
                                    options: [.transitionFlipFromLeft],
                                    animations: {
                                        tempCardView.isFaceUp = false
                                }, completion: { _ in
                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                        withDuration: 0.5,
                                        delay: 0,
                                        options: [],
                                        animations: {
                                            tempCardView.alpha = 0
                                    },
                                        completion: { (_) in
                                            tempCardView.removeFromSuperview()
                                    })
                                })
                                
                            })
                    })
                    
                }
            }
            dealtCards(dealtButton)
        }
    }
    
    private func layingOutAnimation() {
        if !setGame.deck.isEmpty {
            view.isUserInteractionEnabled = false
        }
        var time = 0.0
        var count = 0
        for index in boardView.cardViews.indices {
            let cardView = boardView.cardViews[index]
            if !cardView.isFaceUp, !dealtButton.isHidden {
                time += 0.3
                cardView.alpha = 1
                let startFrame = cardView.frame
                cardView.frame = CGRect(
                    origin: CGPoint(
                        x: dealtButton.frame.origin.x - boardView.frame.origin.x,
                        y: dealtButton.frame.origin.y - boardView.frame.origin.y),
                    size: dealtButton.frame.size)
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.5,
                    delay: time,
                    options: [],
                    animations: {
                        cardView.frame = startFrame
                },
                    completion: { position in
                        UIView.transition(
                            with: cardView,
                            duration: 0.5,
                            options: [.transitionFlipFromLeft],
                            animations: {
                                cardView.isFaceUp = true
                        },
                            completion: { _ in
                                count += 1
                                if index == self.boardView.cardViews.count - 1 || (self.setGame.deck.count != 69 && count == 3) {
                                    self.view.isUserInteractionEnabled = true
                                }
                        })
                })
            }
        }
        dealtButton.isHidden = setGame.deck.count != 0 ? false : true
    }
    
}



