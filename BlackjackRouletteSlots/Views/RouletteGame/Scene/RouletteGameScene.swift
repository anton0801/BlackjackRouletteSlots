import SwiftUI
import SpriteKit

class RouletteGameScene: SKScene {
    
    private var menuButton: SKSpriteNode!
    private var rulesNode: SKSpriteNode!
    private var startRoulette: SKSpriteNode!
    private var restartBtn: SKSpriteNode!
    
    private var rouletteBoardNode: RouletteBoardNode!
    
    private var rouletteNode: RouletteNode!
    
    private var balance = UserDefaults.standard.integer(forKey: "userBalance") {
        didSet {
            balanceLabel.text = "\(balance)"
            UserDefaults.standard.set(balance, forKey: "userBalance")
        }
    }
    private var balanceLabel: SKLabelNode!
    
    private var betChips = [
        BetChip(betValue: 1, src: "chip_1"),
        BetChip(betValue: 5, src: "chip_5"),
        BetChip(betValue: 10, src: "chip_10"),
        BetChip(betValue: 20, src: "chip_20"),
        BetChip(betValue: 50, src: "chip_50"),
        BetChip(betValue: 100, src: "chip_100")
    ]
    
    var maxBets = 15
    var currentBets = 0
    
    // MARK: изменить логику betsPlaced
    private var betsPlaced: [String: (String, BetChip)] = [:] {
        didSet {
            if !betsPlaced.isEmpty {
                totalBet = betsPlaced.map { $0.value.1.betValue }.reduce(0, +)
            }
        }
    }
    private var totalBet: Int = 0
    
    override func didMove(to view: SKView) {
        size = CGSize(width: 1350, height: 750)
        
        createUIGame()
    }
    
    func restartScene() -> RouletteGameScene {
        let newGameScene = RouletteGameScene()
        view?.presentScene(newGameScene)
        return newGameScene
    }
    
    private func createUIGame() {
        let back = createBackground()
        addChild(back)
        
        menuButton = createSpriteNode(src: "menu_btn", size: CGSize(width: 120, height: 190), position: CGPoint(x: 70, y: size.height - 110), name: "menu_btn")
        menuButton.zPosition = 15
        addChild(menuButton)
        
        rulesNode = createSpriteNode(src: "rules_btn", size: CGSize(width: 120, height: 190), position: CGPoint(x: 70, y: size.height - 310), name: "rules_btn")
        addChild(rulesNode)
        
        startRoulette = createSpriteNode(src: "start_roulette", size: CGSize(width: 300, height: 180), position: CGPoint(x: size.width / 2, y: 80), name: "start_roulette")
        addChild(startRoulette)
        
        let balanceBack = createSpriteNode(src: "score", size: CGSize(width: 200, height: 120), position: CGPoint(x: size.width - 280, y: 80))
        addChild(balanceBack)
        
        balanceLabel = SKLabelNode(text: "\(balance)")
        balanceLabel.fontColor = .white
        balanceLabel.fontSize = 32
        balanceLabel.position = CGPoint(x: size.width - 250, y: 70)
        balanceLabel.fontName = "Calistoga-Regular"
        addChild(balanceLabel)
        
        createBetChips()
        
        rouletteBoardNode = RouletteBoardNode(size: CGSize(width: 1000, height: 500))
        rouletteBoardNode.position = CGPoint(x: size.width / 2 + 80, y: size.height / 2 + 100)
        addChild(rouletteBoardNode)
        
        rouletteNode = RouletteNode(size: CGSize(width: 400, height: 400))
        rouletteNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
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
    
    private var selectedChip: SKNode?
    private var betChip: BetChip?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            let touchedNodes = nodes(at: loc)
            
            for node in touchedNodes {
                if node.name?.starts(with: "placedchip") == true {
                    let betId = node.name!.components(separatedBy: "_")[1]
                    let betPlaced = betsPlaced[betId]!
                    balance += betPlaced.1.betValue
                    betsPlaced.removeValue(forKey: betId)
                    node.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))
                    currentBets -= 1
                    placedBetsNodes.removeValue(forKey: betId)
                    return
                }
                
                if node.name?.contains("chip") == true {
                    selectedChip?.run(SKAction.scale(to: 1, duration: 0.3))
                    selectedChip = node
                    node.run(SKAction.scale(to: 1.1, duration: 0.3))
                    let placedBet = Int(node.name!.components(separatedBy: "_")[1])
                    if let placedBet = placedBet {
                        if let betChip = betChips.filter({ $0.betValue == placedBet }).first {
                            self.betChip = betChip
                            return
                        }
                    }
                }
                
                if node.name?.contains("bet_") == true {
                    if currentBets < maxBets {
                        let betName = node.name!
                        createChipInBoard(betItemName: betName, location: loc)
                    } else {
                        NotificationCenter.default.post(name: Notification.Name("show_alert"), object: nil, userInfo: ["title": "Bet error!", "message": "You cannot place more than 15 bets per spin"])
                    }
                    return
                }
                
                if node == startRoulette {
                    if !betsPlaced.isEmpty {
                        startGameRoulette()
                    } else {
                        NotificationCenter.default.post(name: Notification.Name("show_alert"), object: nil, userInfo: ["title": "Error!", "message": "Put any bet before starting the spinning the roulette!"])
                    }
                    return
                }
                
                if node == menuButton {
                    NotificationCenter.default.post(name: Notification.Name("go_menu"), object: nil)
                }
                
                if node == restartBtn {
                    NotificationCenter.default.post(name: Notification.Name("restart_btn"), object: nil)
                }
                
                if node == rulesNode {
                    NotificationCenter.default.post(name: Notification.Name("open_rules"), object: nil)
                }
            }
        }
    }
    
    private var placedBetsNodes: [String: SKNode] = [:]
    
    private func createChipInBoard(betItemName: String, location: CGPoint) {
        guard let _ = selectedChip,
              let betChip = betChip else { return }
        
        if balance >= betChip.betValue {
            let chipSize: CGFloat = 62
            let chipPlaceid = UUID().uuidString
            
            currentBets += 1
            betsPlaced[chipPlaceid] = (betItemName, betChip)
            balance -= betChip.betValue
            
            let chipNode = createSpriteNode(src: betChip.src, size: CGSize(width: chipSize, height: chipSize), position: location, name: "placedchip_\(chipPlaceid)")
            addChild(chipNode)
            placedBetsNodes[chipPlaceid] = chipNode
        } else {
            NotificationCenter.default.post(name: Notification.Name("show_alert"), object: nil, userInfo: ["title": "Bet error!", "message": "You don't have enough credits to make that bet!"])
        }
    }
    
    private func startGameRoulette() {
        let actionFadeOut = SKAction.fadeOut(withDuration: 0.3)
        let actionRM = SKAction.removeFromParent()
        let seq = SKAction.sequence([actionFadeOut, actionRM])
        for (_, betChip) in placedBetsNodes {
            betChip.run(seq)
        }
        startRoulette.run(seq)
        rouletteBoardNode.run(seq) {
            self.addChild(self.rouletteNode)
            self.rouletteNode.run(SKAction.fadeIn(withDuration: 0.3)) {
                self.rouletteNode.startRoulette { segment in
                    if let winSegmnet = Int(segment) {
                        let totalWinings = self.calculateWinnings(winningNumber: winSegmnet)
                        self.showWinningNode(wins: totalWinings)
                    } else {
                        self.showWinningNode(wins: 0)
                    }
                }
            }
        }
    }
    
    
    private func showWinningNode(wins: Int) {
        let background = SKSpriteNode(color: .black.withAlphaComponent(0.6), size: size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 10
        addChild(background)
        
        let text = "YOU WIN: \(wins)"
        balance += wins
        
        let label: SKLabelNode = SKLabelNode(text: text)
        label.fontName = "Calistoga-Regular"
        label.fontSize = 132
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 11
        addChild(label)
        
        restartBtn = createSpriteNode(src: "restart_btn", size: CGSize(width: 250, height: 120), position: CGPoint(x: size.width - 150, y: 80), name: "restart_btn")
        restartBtn.zPosition = 15
        addChild(restartBtn)
    }
    
    func calculateWinnings(winningNumber: Int) -> Int {
        let redNumbers: Set<Int> = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
        let blackNumbers: Set<Int> = [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35]
        
        var totalWinnings = 0
        
        // Helper functions to categorize numbers
        func isRed(number: Int) -> Bool {
            return redNumbers.contains(number)
        }
        
        func isBlack(number: Int) -> Bool {
            return blackNumbers.contains(number)
        }
        
        func isEven(number: Int) -> Bool {
            return number % 2 == 0
        }
        
        func isOdd(number: Int) -> Bool {
            return number % 2 != 0
        }
        
        func inRange(number: Int, start: Int, end: Int) -> Bool {
            return number >= start && number <= end
        }
        
        // Loop through all bets placed
        for (_, (betItemName, betChip)) in betsPlaced {
            let betAmount = betChip.betValue
            var winMultiplier = 0
            
            switch betItemName {
            case "bet_\(winningNumber)":
                winMultiplier = 35 // Exact number bet pays 35:1
                
            case "bet_red_btn":
                if isRed(number: winningNumber) {
                    winMultiplier = 1 // Color bet pays 1:1
                }
                
            case "bet_black_btn":
                if isBlack(number: winningNumber) {
                    winMultiplier = 1
                }
                
            case "bet_odd_btn":
                if isOdd(number: winningNumber) {
                    winMultiplier = 1
                }
                
            case "bet_even_btn":
                if isEven(number: winningNumber) {
                    winMultiplier = 1
                }
                
            case "bet_1to18_btn":
                if inRange(number: winningNumber, start: 1, end: 18) {
                    winMultiplier = 1
                }
                
            case "bet_19to36_btn":
                if inRange(number: winningNumber, start: 19, end: 36) {
                    winMultiplier = 1
                }
                
            case "bet_1st12":
                if inRange(number: winningNumber, start: 1, end: 12) {
                    winMultiplier = 2 // Column bets pay 2:1
                }
                
            case "bet_2nd12":
                if inRange(number: winningNumber, start: 13, end: 24) {
                    winMultiplier = 2
                }
                
            case "bet_3rd12":
                if inRange(number: winningNumber, start: 25, end: 36) {
                    winMultiplier = 2
                }
                
            case "bet_2to1row_1":
                if winningNumber % 3 == 1 {
                    winMultiplier = 2
                }
                
            case "bet_2to1row_2":
                if winningNumber % 3 == 2 {
                    winMultiplier = 2
                }
                
            case "bet_2to1row_3":
                if winningNumber % 3 == 0 {
                    winMultiplier = 2
                }
                
            case "bet_0":
                if winningNumber == 0 {
                    winMultiplier = 35
                }
                
            case "bet_00":
                if winningNumber == -1 { // Assuming 37 is used to represent "00"
                    winMultiplier = 35
                }
                
            default:
                break
            }
            
            // Calculate winnings for this bet
            if winMultiplier > 0 {
                totalWinnings += betAmount * winMultiplier
            }
        }
        
        return totalWinnings
    }
    
    
}


#Preview {
    VStack {
        SpriteView(scene: RouletteGameScene())
            .ignoresSafeArea()
    }
}
