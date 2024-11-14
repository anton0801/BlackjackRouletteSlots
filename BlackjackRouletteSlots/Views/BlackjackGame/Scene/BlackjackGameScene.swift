import SpriteKit
import SwiftUI

struct Card: Equatable {
    var cardValue: [Int]
    var cardSrc: String
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.cardSrc == rhs.cardSrc
    }
}

struct BetChip {
    var betValue: Int
    var src: String
}

enum GameState {
    case winDiller, winPlayer, draw, none
}

class BlackjackGameScene: SKScene {
    
    private var menuButton: SKSpriteNode!
    private var rulesNode: SKSpriteNode!
    
    private var betBtn: SKSpriteNode!
    private var restartBtn: SKSpriteNode!
    
    private var checkBtn: SKSpriteNode!
    private var hitMeBtn: SKSpriteNode!
    
    private var betsPlaced: [BetChip] = [] {
        didSet {
            if !betsPlaced.isEmpty {
                totalBet = betsPlaced.map { $0.betValue }.reduce(0, +)
            }
        }
    }
    private var totalBet: Int = 0
    
    private var balance = UserDefaults.standard.integer(forKey: "userBalance") {
        didSet {
            balanceLabel.text = "\(balance)"
            UserDefaults.standard.set(balance, forKey: "userBalance")
        }
    }
    private var balanceLabel: SKLabelNode!
    
    private var gameState: GameState = .none {
        didSet {
            if gameState != .none {
                showResultGame()
            }
        }
    }
    
    private var dillerCards: [Card] = []
    private var playerCards: [Card] = []
    
    private var betChips = [
        BetChip(betValue: 1, src: "chip_1"),
        BetChip(betValue: 5, src: "chip_5"),
        BetChip(betValue: 10, src: "chip_10"),
        BetChip(betValue: 20, src: "chip_20"),
        BetChip(betValue: 50, src: "chip_50"),
        BetChip(betValue: 100, src: "chip_100")
    ]
    
    func restartScene() -> BlackjackGameScene {
        let newGameScene = BlackjackGameScene()
        view?.presentScene(newGameScene)
        return newGameScene
    }
    
    override func didMove(to view: SKView) {
        size = CGSize(width: 1350, height: 750)
        
        createUIGame()
    }
    
    private func createUIGame() {
        let back = createBackground()
        addChild(back)
        
        menuButton = createSpriteNode(src: "menu_btn", size: CGSize(width: 120, height: 190), position: CGPoint(x: 70, y: size.height - 110), name: "menu_btn")
        menuButton.zPosition = 15
        addChild(menuButton)
        
        rulesNode = createSpriteNode(src: "rules_btn", size: CGSize(width: 120, height: 190), position: CGPoint(x: 70, y: size.height - 310), name: "rules_btn")
        addChild(rulesNode)
        
        let balanceBack = createSpriteNode(src: "score", size: CGSize(width: 150, height: 120), position: CGPoint(x: 230, y: size.height - 80))
        addChild(balanceBack)
        
        balanceLabel = SKLabelNode(text: "\(balance)")
        balanceLabel.fontColor = .white
        balanceLabel.fontSize = 32
        balanceLabel.position = CGPoint(x: 240, y: size.height - 90)
        balanceLabel.fontName = "Calistoga-Regular"
        addChild(balanceLabel)
        
        let forBet = createSpriteNode(src: "for_bet", size: CGSize(width: 280, height: 110), position: CGPoint(x: size.width / 2, y: 220))
        addChild(forBet)
        
        betBtn = createSpriteNode(src: "bet_btn", size: CGSize(width: 250, height: 120), position: CGPoint(x: size.width / 2, y: 80), name: "bet_btn")
        addChild(betBtn)
        
        restartBtn = createSpriteNode(src: "restart_btn", size: CGSize(width: 250, height: 120), position: CGPoint(x: size.width - 150, y: 80), name: "restart_btn")
        restartBtn.zPosition = 15
        addChild(restartBtn)
        
        hitMeBtn = createSpriteNode(src: "hit_me_btn", size: CGSize(width: 250, height: 120), position: CGPoint(x: size.width - 150, y: 80), name: "hit_me_btn")
        hitMeBtn.alpha = 0
        
        checkBtn = createSpriteNode(src: "check_btn", size: CGSize(width: 250, height: 120), position: CGPoint(x: size.width - 420, y: 80), name: "check_btn")
        checkBtn.alpha = 0
        
        let cardFaceUp = createSpriteNode(src: "card_face_down", size: CGSize(width: 80, height: 130), position: CGPoint(x: size.width / 2 + 350, y: 400))
        cardFaceUp.zPosition = 5
        addChild(cardFaceUp)
        
        createBetChips()
    }
    
    private func createBetChips() {
        let startPoint: CGFloat = 70
        let chipSize: CGFloat = 92
        var indexChip = 0
        for (index, betChip) in betChips.enumerated() {
            let chipPositionI = ((chipSize + 25) * CGFloat(indexChip)) + startPoint
            let chipPostionY: CGFloat = index < 3 ? 100 : 220
            let chipNode = createSpriteNode(src: betChip.src, size: CGSize(width: chipSize, height: chipSize), position: CGPoint(x: chipPositionI, y: chipPostionY), name: "chip_\(betChip.betValue)")
            addChild(chipNode)
            indexChip += 1
            if index == 2 {
                indexChip = 0
            }
        }
    }
    
    private func createBackground() -> SKSpriteNode {
        let nodeBack = SKSpriteNode(imageNamed: "blackjack_game_back")
        nodeBack.position = CGPoint(x: size.width / 2, y: size.height / 2)
        nodeBack.size = size
        nodeBack.zPosition = -1
        return nodeBack
    }
    
    private func createSpriteNode(src: String, size: CGSize, position: CGPoint, name: String? = nil) -> SKSpriteNode {
        let createNode = SKSpriteNode(imageNamed: src)
        createNode.size = size
        createNode.position = position
        createNode.name = name
        return createNode
    }
    
    private var selectedChipNode: SKSpriteNode?
    private var selectedChip: BetChip?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            
            for node in nodes(at: loc) {
                if node.name?.contains("chip") == true {
                    let placedBet = Int(node.name!.components(separatedBy: "_")[1])
                    if let placedBet = placedBet {
                        if let betChip = betChips.filter({ $0.betValue == placedBet }).first {
                            placeBet(placedChip: betChip)
                            return
                        }
                    }
                }
                
                if node == hitMeBtn {
                    let _ = getOneMorePlayerCard()
                    return
                }
                
                if node == checkBtn {
                    checkDillerCards()
                    return
                }
                
                if node == menuButton {
                    NotificationCenter.default.post(name: Notification.Name("go_menu"), object: nil)
                }
                
                if node == restartBtn {
                    NotificationCenter.default.post(name: Notification.Name("restart_btn"), object: nil)
                }
                
                if node == rulesNode {
                    NotificationCenter.default.post(name: Notification.Name("open_info"), object: nil)
                }
                
                if node == betBtn {
                    startGame()
                }
            }
        }
    }
    
    private func placeBet(placedChip: BetChip) {
        let morePlacedBet = placedChip.betValue
        if balance >= (totalBet + morePlacedBet) {
            if betsPlaced.count < 6 {
                betsPlaced.append(placedChip)
                
                let startPoint = size.width / 2 - 120
                let indexChip = betsPlaced.count - 1
                
                let chipPositionI: CGFloat = ((42) * CGFloat(indexChip)) + startPoint
                let chipPostionY: CGFloat = 220
                let chipNode = createSpriteNode(src: placedChip.src, size: CGSize(width: 92, height: 92), position: CGPoint(x: chipPositionI, y: chipPostionY))
                chipNode.zPosition = CGFloat(indexChip + 1)
                addChild(chipNode)
            } else {
                NotificationCenter.default.post(name: Notification.Name("show_alert"), object: nil, userInfo: ["title": "Bet error!", "message": "You can put only 6 bet chips on the table."])
            }
        } else {
            NotificationCenter.default.post(name: Notification.Name("show_alert"), object: nil, userInfo: ["title": "Bet error!", "message": "You don't have enought credits to use place this bet more."])
        }
    }
    
    private func startGame() {
        if !betsPlaced.isEmpty {
            deskCards()
            showNeededButtonsForGame()
        } else {
            NotificationCenter.default.post(name: Notification.Name("show_alert"), object: nil, userInfo: ["title": "Error!", "message": "To start game, place bets first!"])
        }
    }
    
    var shuffledCards = cards.shuffled()
    
    private func deskCards() {
        let deskCards = Array(shuffledCards.prefix(2))
        shuffledCards.removeAll { card in
            deskCards.contains(card)
        }
        let deskCards2 = Array(shuffledCards.prefix(2))
        dillerCards = deskCards
        playerCards = deskCards2
        
        for (index, playerCard) in playerCards.enumerated() {
            placeCard(card: playerCard, cardPos: CGFloat(index), startPoint: CGPoint(x: size.width / 2 - 50, y: size.height / 2))
        }
        
        for (index, dillerCard) in dillerCards.enumerated() {
            if index == 0 {
                placeCard(card: dillerCard, cardPos: CGFloat(index), startPoint: CGPoint(x: size.width / 2 - 50, y: size.height / 2 + 200))
            } else if index == 1 {
                placeCard(card: dillerCard, cardPos: CGFloat(index), startPoint: CGPoint(x: size.width / 2 - 50, y: size.height / 2 + 200), isFaceDown: true)
            }
        }
        
        checkCards(cards: playerCards)
    }
    
    private func getOneMorePlayerCard() -> Card {
        let deskCard = Array(shuffledCards.prefix(1))[0]
        shuffledCards.removeAll { card in
            card.cardSrc == deskCard.cardSrc
        }
        playerCards.append(deskCard)
        placeCard(card: deskCard, cardPos: CGFloat(playerCards.count - 1), startPoint: CGPoint(x: size.width / 2 - 50, y: size.height / 2)) {
            self.checkCards(cards: self.playerCards)
        }
        return deskCard
    }
    
    private func getOneMoreDillerCard() -> Card {
        let deskCard = Array(shuffledCards.prefix(1))[0]
        shuffledCards.removeAll { card in
            card.cardSrc == deskCard.cardSrc
        }
        dillerCards.append(deskCard)
        placeCard(card: deskCard, cardPos: CGFloat(dillerCards.count - 1), startPoint: CGPoint(x: size.width / 2 - 50, y: size.height / 2 + 200)) {
            self.checkDillerCards()
        }
        return deskCard
    }
    
    private func placeCard(card: Card, cardPos: CGFloat, startPoint: CGPoint, isFaceDown: Bool = false, completion: (() -> Void)? = nil) {
        let startPositionCardsPlaced = CGPoint(x: size.width / 2 + 350, y: 400)
        let cardNode = createSpriteNode(src: isFaceDown ? "card_face_down" : card.cardSrc, size: CGSize(width: 80, height: 120), position: startPositionCardsPlaced)
        addChild(cardNode)
        let positionFinalCardX: CGFloat = startPoint.x + (cardPos * (cardNode.size.width - 30))
        let actionMove = SKAction.move(to: CGPoint(x: positionFinalCardX, y: startPoint.y), duration: 0.6)
        let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 0.3)
        let rotateRepeate = SKAction.repeat(rotateAction, count: 2)
        let group = SKAction.group([actionMove, rotateRepeate])
        cardNode.run(group) {
            completion?()
        }
    }
    
    private func showNeededButtonsForGame() {
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let fadeSeq = SKAction.sequence([fadeOutAction, SKAction.removeFromParent()])
        let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
        
        betBtn.run(fadeSeq)
        restartBtn.run(fadeSeq) {
            self.addChild(self.checkBtn)
            self.checkBtn.run(fadeInAction)
            self.addChild(self.hitMeBtn)
            self.hitMeBtn.run(fadeInAction)
        }
    }
    
    private func fadeOutGameButtons() {
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let fadeSeq = SKAction.sequence([fadeOutAction, SKAction.removeFromParent()])
        let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
        
        self.checkBtn.run(fadeSeq)
        self.hitMeBtn.run(fadeSeq) {
            self.addChild(self.restartBtn)
            self.restartBtn.run(fadeInAction)
        }
    }
    
    private func checkCards(cards: [Card]) {
        let hand = Hand(cards: cards)
        
        if hand.score == 21 && cards.count == 2 {
            // open automatically diller cards
            blackjack = true
            openDillerCards()
        } else if hand.score > 21 {
            gameState = .winDiller
        }
    }
    
    private func openDillerCards() {
        // открываем закрытую карту дилера
        let node = atPoint(CGPoint(x: (size.width / 2 - 50)  + (1 * (80 - 30)), y: size.height / 2 + 200))
        node.run(SKAction.setTexture(SKTexture(imageNamed: dillerCards[1].cardSrc)))
        cardDillerOpened = true
        
        // проверяем есть ли у диллера blackjack
        let hand = Hand(cards: dillerCards)
        if hand.score == 21 {
            gameState = .draw
        } else {
            gameState = .winPlayer
        }
    }
    
    private var cardDillerOpened = false
    private var blackjack = false
    
    private func checkDillerCards() {
        if !cardDillerOpened {
            let node = atPoint(CGPoint(x: (size.width / 2 - 50) + (1 * (80 - 30)), y: size.height / 2 + 200))
            node.run(SKAction.setTexture(SKTexture(imageNamed: dillerCards[1].cardSrc)))
            cardDillerOpened = true
        }

        // Проверка состояния дилера после открытия карт
        let playerHand = Hand(cards: playerCards)
        var dillerHand = Hand(cards: dillerCards)
        
        // Дилер берет карты, пока его счет меньше 17
        while dillerHand.score < 17 {
            let newCard = getOneMoreDillerCard()
            dillerCards.append(newCard)
            dillerHand = Hand(cards: dillerCards)
        }

        if dillerHand.score > 21 {
            gameState = .winPlayer // Дилер проиграл, если его счет больше 21
        } else if dillerHand.score >= playerHand.score {
            gameState = .winDiller // Если у дилера больше очков или столько же, сколько у игрока
        } else if dillerHand.score == playerHand.score {
            gameState = .draw
        } else {
            gameState = .winPlayer // Если у игрока больше очков, чем у дилера
        }
    }
    
    private func showResultGame() {
        fadeOutGameButtons()
        let background = SKSpriteNode(color: .black.withAlphaComponent(0.4), size: size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 10
        addChild(background)
        
        var text = "YOU LOSE"
        if gameState == .winPlayer {
            if blackjack {
                balance += totalBet * 3
                text = "+\(totalBet * 3)"
            } else {
                balance += totalBet * 2
                text = "+\(totalBet * 2)"
            }
        } else if gameState == .draw {
            text = "DRAW"
        }
        let label: SKLabelNode = SKLabelNode(text: text)
        label.fontName = "Calistoga-Regular"
        label.fontSize = 132
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 11
        addChild(label)
    }
    
}

struct Hand {
    init<Cards: Sequence>(cards: Cards) where Cards.Element == Card {
        let reduction = cards.reduce(into: (score: 0, aceCount: 0)) { result, card in
            switch card.cardValue {
            case [1, 11]: // Если карта - туз
                result.score += 1  // Считаем тузы как 1, добавляем к aceCount
                result.aceCount += 1
            case [10]: // Если карта - десятка, валет, дама, король
                result.score += 10
            default:
                // Для других карт просто добавляем значение
                result.score += card.cardValue[0]
            }
        }

        // Изначально установим score и скорректируем тузы, если это не приведет к превышению 21
        var score = reduction.score
        (0..<reduction.aceCount).forEach { _ in
            if score <= 11 {
                score += 10 // Увеличиваем значение туза до 11, если это безопасно
            }
        }
        self.score = score
    }

    let score: Int
}

#Preview {
    VStack {
        SpriteView(scene: BlackjackGameScene())
            .ignoresSafeArea()
    }
}

var cards = [
    // HEARTS
    Card(cardValue: [2], cardSrc: "hearts_2"),
    Card(cardValue: [3], cardSrc: "hearts_3"),
    Card(cardValue: [4], cardSrc: "hearts_4"),
    Card(cardValue: [5], cardSrc: "hearts_5"),
    Card(cardValue: [6], cardSrc: "hearts_6"),
    Card(cardValue: [7], cardSrc: "hearts_7"),
    Card(cardValue: [8], cardSrc: "hearts_8"),
    Card(cardValue: [9], cardSrc: "hearts_9"),
    Card(cardValue: [10], cardSrc: "hearts_10"),
    Card(cardValue: [10], cardSrc: "hearts_jak"),
    Card(cardValue: [10], cardSrc: "hearts_queen"),
    Card(cardValue: [10], cardSrc: "hearts_king"),
    Card(cardValue: [1, 11], cardSrc: "hearts_ace"),
    // PIKES
    Card(cardValue: [2], cardSrc: "pikes_2"),
    Card(cardValue: [3], cardSrc: "pikes_3"),
    Card(cardValue: [4], cardSrc: "pikes_4"),
    Card(cardValue: [5], cardSrc: "pikes_5"),
    Card(cardValue: [6], cardSrc: "pikes_6"),
    Card(cardValue: [7], cardSrc: "pikes_7"),
    Card(cardValue: [8], cardSrc: "pikes_8"),
    Card(cardValue: [9], cardSrc: "pikes_9"),
    Card(cardValue: [10], cardSrc: "pikes_10"),
    Card(cardValue: [10], cardSrc: "pikes_jak"),
    Card(cardValue: [10], cardSrc: "pikes_queen"),
    Card(cardValue: [10], cardSrc: "pikes_king"),
    Card(cardValue: [1, 11], cardSrc: "pikes_ace"),
    // TILES
    Card(cardValue: [2], cardSrc: "tiles_2"),
    Card(cardValue: [3], cardSrc: "tiles_3"),
    Card(cardValue: [4], cardSrc: "tiles_4"),
    Card(cardValue: [5], cardSrc: "tiles_5"),
    Card(cardValue: [6], cardSrc: "tiles_6"),
    Card(cardValue: [7], cardSrc: "tiles_7"),
    Card(cardValue: [8], cardSrc: "tiles_8"),
    Card(cardValue: [9], cardSrc: "tiles_9"),
    Card(cardValue: [10], cardSrc: "tiles_10"),
    Card(cardValue: [10], cardSrc: "tiles_jak"),
    Card(cardValue: [10], cardSrc: "tiles_queen"),
    Card(cardValue: [10], cardSrc: "tiles_king"),
    Card(cardValue: [1, 11], cardSrc: "tiles_ace"),
    // CLOVERS
    Card(cardValue: [2], cardSrc: "clovers_2"),
    Card(cardValue: [3], cardSrc: "clovers_3"),
    Card(cardValue: [4], cardSrc: "clovers_4"),
    Card(cardValue: [5], cardSrc: "clovers_5"),
    Card(cardValue: [6], cardSrc: "clovers_6"),
    Card(cardValue: [7], cardSrc: "clovers_7"),
    Card(cardValue: [8], cardSrc: "clovers_8"),
    Card(cardValue: [9], cardSrc: "clovers_9"),
    Card(cardValue: [10], cardSrc: "clovers_10"),
    Card(cardValue: [10], cardSrc: "clovers_jak"),
    Card(cardValue: [10], cardSrc: "clovers_queen"),
    Card(cardValue: [10], cardSrc: "clovers_king"),
    Card(cardValue: [1, 11], cardSrc: "clovers_ace"),
]
