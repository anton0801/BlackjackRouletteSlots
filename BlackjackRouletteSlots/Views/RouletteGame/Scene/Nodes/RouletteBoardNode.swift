import SpriteKit

enum SlotColor: String {
    case red = "red_bg"
    case black = "black_bg"
    case zeros
}

class RouletteBoardNode: SKSpriteNode {
    
    init(size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        createRouletteBoard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createRouletteBoard() {
        // Base node for the entire board
        let boardNode = SKSpriteNode(imageNamed: "board_roulette")
        boardNode.size = size
        addChild(boardNode)
        
        // Define dimensions for slots
        let slotWidth: CGFloat = 50
        let slotHeight: CGFloat = 70
        
        // Define colors for numbers
        let redNumbers: Set<Int> = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
        let blackNumbers: Set<Int> = [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35]
        
        // Create number slots (rows and columns based on the grid layout)
        for row in 0..<3 {
            for col in 0..<12 {
                let number = col * 3 + row + 1
                let slotColor: SlotColor
                
                // Determine slot color based on the number
                if redNumbers.contains(number) {
                    slotColor = .red
                } else if blackNumbers.contains(number) {
                    slotColor = .black
                } else {
                    slotColor = .zeros
                }
                
                // Create slot node
                let slotNode = SKSpriteNode(color: .clear, size: CGSize(width: slotWidth, height: slotHeight))
                slotNode.position = CGPoint(x: (CGFloat(col) * (slotWidth + 17)) - 7 * slotWidth, y: (CGFloat(row) * (slotHeight + 28)))
                slotNode.name = "bet_\(number)"
                boardNode.addChild(slotNode)
                
                let slotBack = SKSpriteNode(imageNamed: slotColor.rawValue)
                slotBack.size = slotNode.size
                slotNode.addChild(slotBack)
                
                // Create number label
                let labelNode = SKLabelNode(text: "\(number)")
                labelNode.fontSize = 32
                labelNode.fontColor = .white
                labelNode.fontName = "Calistoga-Regular"
                labelNode.position = CGPoint(x: 0, y: -labelNode.frame.height / 2)
                slotNode.addChild(labelNode)
            }
        }
        
        addZeroSlot(to: boardNode, label: "0", x: -430, y: 20, name: "bet_0")
        addZeroSlot(to: boardNode, label: "00", x: -430, y: 170, name: "bet_00")
        
        addBettingAreaImage(to: boardNode, src: "red_bet", x: -45, y: -160, width: 82, height: 52, name: "bet_red_btn")
        addBettingAreaImage(to: boardNode, src: "black_bet", x: 90, y: -160, width: 82, height: 52, name: "bet_black_btn")
        
        addBettingAreaLabel(to: boardNode, text: "ODD", x: 225, y: -200, width: 82, height: 52, name: "bet_odd_btn")
        addBettingAreaLabel(to: boardNode, text: "10 to 36", x: 360, y: -200, width: 82, height: 52, name: "bet_19to36_btn")
        
        addBettingAreaLabel(to: boardNode, text: "EVEN", x: -175, y: -200, width: 82, height: 52, name: "bet_even_btn")
        addBettingAreaLabel(to: boardNode, text: "1 to 18", x: -320, y: -200, width: 82, height: 52, name: "bet_1to18_btn")
        
        addBettingAreaLabel(to: boardNode, text: "1st 12", x: -240, y: -110, width: 82, height: 52, name: "bet_1st12")
        addBettingAreaLabel(to: boardNode, text: "2nd 12", x: 20, y: -110, width: 82, height: 52, name: "bet_2nd12")
        addBettingAreaLabel(to: boardNode, text: "3rd 12", x: 290, y: -110, width: 82, height: 52, name: "bet_3rd12")
        
        addZeroSlot(to: boardNode, label: "2 to 1", x: 455, y: 0, name: "bet_2to1row_3")
        addZeroSlot(to: boardNode, label: "2 to 1", x: 455, y: 90, name: "bet_2to1row_2")
        addZeroSlot(to: boardNode, label: "2 to 1", x: 455, y: 190, name: "bet_2to1row_1")
    }
    
    func addZeroSlot(to parentNode: SKNode, label: String, x: CGFloat, y: CGFloat, name: String) {
        let slotNode = SKSpriteNode()
        slotNode.position = CGPoint(x: x, y: y)
        slotNode.name = name
        parentNode.addChild(slotNode)
        
        let labelNode = SKLabelNode(text: label)
        labelNode.fontSize = 32
        labelNode.fontColor = .white
        labelNode.fontName = "Calistoga-Regular"
        labelNode.position = CGPoint(x: 0, y: -labelNode.frame.height / 2)
        slotNode.addChild(labelNode)
        
        slotNode.zRotation = .pi / 2
    }
    
    func addBettingAreaLabel(to parentNode: SKNode, text: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, name: String) {
        let areaNode = SKSpriteNode(color: .clear, size: CGSize(width: width, height: height))
        areaNode.name = name
        areaNode.position = CGPoint(x: x, y: y)
        
        let labelNode = SKLabelNode(text: text)
        labelNode.fontSize = 32
        labelNode.fontColor = .white
        labelNode.fontName = "Calistoga-Regular"
        labelNode.position = CGPoint(x: 0, y: -labelNode.frame.height / 2)
        areaNode.addChild(labelNode)
        
        parentNode.addChild(areaNode)
    }
    
    func addBettingAreaImage(to parentNode: SKNode, src: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, name: String) {
        let areaNode = SKSpriteNode(color: .clear, size: CGSize(width: width, height: height))
        areaNode.name = name
        areaNode.position = CGPoint(x: x, y: y)
        
        let node = SKSpriteNode(imageNamed: src)
        node.position = CGPoint(x: 0, y: -node.frame.height / 2)
        node.size = CGSize(width: width, height: height)
        areaNode.addChild(node)
        
        parentNode.addChild(areaNode)
    }
    
}
