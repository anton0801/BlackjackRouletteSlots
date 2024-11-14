import SpriteKit

class RouletteNode: SKSpriteNode {
    
    private var rouletteSpin: SKSpriteNode
    private var rouletteBall: SKSpriteNode
    private var wheelDetermineLayer: SKSpriteNode
    
    let wheelSegments = 38
    let segmentPrizes = [
        -1,27,10,25,29,12,8,19,31,18,6,21,33,16,4,23,35,14,2,0,28,9,26,30,11,7,20,32,17,5,22,34,15,3,24,36,13,1
    ]
    
    init(size: CGSize) {
        rouletteSpin = SKSpriteNode(imageNamed: "roulette_spin")
        rouletteSpin.size = CGSize(width: size.width * 0.7, height: size.height * 0.7)
        
        rouletteBall = SKSpriteNode(imageNamed: "roulette_ball")
        rouletteBall.size = CGSize(width: 24, height: 24)
        rouletteBall.position = CGPoint(x: 0, y: (size.height / 2 - 70))
        
        let rouletteWheel = SKSpriteNode(imageNamed: "roulette_wheel")
        rouletteWheel.size = size
        let rouletteSpine = SKSpriteNode(imageNamed: "roulette_spine")
        rouletteSpine.size = CGSize(width: size.width * 0.2, height: size.height * 0.2)
        
        wheelDetermineLayer = SKSpriteNode(color: .clear, size: rouletteSpin.size)
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(rouletteWheel)
        addChild(rouletteSpin)
        addChild(rouletteSpine)
        addChild(rouletteBall)
        addChild(wheelDetermineLayer)
        
        let itemAngle = 2 * .pi / CGFloat(wheelSegments)
        for i in 0..<wheelSegments {
            let dnode = SKSpriteNode(color: .clear, size: CGSize(width: 300, height: size.height / CGFloat(wheelSegments)))
            dnode.anchorPoint = CGPoint(x: 0.5, y: 1)
            dnode.position = CGPoint(x: 0, y: 0)
            dnode.zRotation = -(itemAngle * CGFloat(i) - .pi / 2)
            dnode.name = "\(segmentPrizes[i])"
            wheelDetermineLayer.addChild(dnode)
        }
        
        // print(atPoint(CGPoint(x: -130, y: 20)).name)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startRoulette(completion: @escaping (String) -> Void) {
        let randomSpin = CGFloat.random(in: 5...10)
        let rotateBy = randomSpin * 2 * .pi
        
        let rotateAction = SKAction.rotate(byAngle: rotateBy, duration: 6.0)
        rotateAction.timingMode = .easeInEaseOut

        rouletteSpin.run(rotateAction)
        wheelDetermineLayer.run(rotateAction)
        
        let radius = rouletteSpin.size.width / 2.0
        
        let randomSpinBall = CGFloat.random(in: 10...15)
        let rotateByBall = randomSpinBall * 2 * .pi
        
        // Create a circular path around the rouletteSpin node
        let circularPath = CGMutablePath()
        circularPath.addArc(
            center: CGPoint.zero,
            radius: radius,
            startAngle: 0,
            endAngle: -rotateByBall,
            clockwise: true
        )
        
        // Move the ball to the starting point of the path
        rouletteBall.position = CGPoint(x: radius, y: 0)
        
        // Create a follow path action for the ball
        let moveAroundCircle = SKAction.follow(circularPath, asOffset: false, orientToPath: true, duration: 6.0)
        moveAroundCircle.timingMode = .easeInEaseOut
        
        // Rotation to simulate the ball rolling
        let rotationAmount = radius * 2 * .pi  // Full rotation based on path circumference
        let rollBall = SKAction.rotate(byAngle: -rotationAmount, duration: 6.0)
        
        // Group action to move along the circle and rotate at the same time
        let combinedAction = SKAction.group([moveAroundCircle, rollBall])
        
        // Run the combined action and call completion when done
        rouletteBall.run(combinedAction) {
            let nodeName = self.atPoint(self.rouletteBall.position).name ?? ""
            completion(nodeName)
        }
    }
    
}
