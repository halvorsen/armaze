//
//  ViewController.swift
//  testMaze2
//
//  Created by Jenn Halvorsen on 8/9/17.
//  Copyright © 2017 Right Brothers. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AudioToolbox

class ViewController: UIViewController, ARSCNViewDelegate, BrothersUIAutoLayout, SCNPhysicsContactDelegate {
    var tap = UITapGestureRecognizer()
    var press = DeepPressGestureRecognizer()
    var ringsFound = 0
    var currentScene = SCNScene()
    var playerNode:SCNNode?
    var chasingGoblins = [SCNNode]()
    var foundGun = false
    var level = ""
    let crosshairView = UIImageView()
//    var gunPosition = [SCNVector3]()
    var nodeForGoblinToFace = SCNNode()
    
    let invisibleCover = UIView()
    let ringLabel = UILabel()
    var points = 0
    let back = UILabel()
    let tier = UILabel()
    let collisionLabel = UILabel()
    let location = UILabel()
    var timer1 = Timer()
    var chasingTimer = Timer()
    var myGameOverView = GameOverView()
    var isFirstBackFunc = true
    var isSessionFirstRunning = true
    var isGunReady = true
    
    
    @IBOutlet var sceneView: ARSCNView!
    //var sceneView = ARSCNView()
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mazes = ["1-1","1-2","1-3","1-4","1-5","1-6","1-7","1-8","1-9",
                     "2-1","2-2","2-3","2-4","2-5","2-6","2-7","2-8","2-9",
                     "3-1","3-2","3-3","3-4","3-5","3-6","3-7","3-8","3-9",
                     "4-1","4-2","4-3","4-4","4-5","4-6","4-7","4-8","4-9",
                     "5-1","5-2","5-3","5-4","5-5","5-6","5-7","5-8","5-9",
                     "6-1","6-2","6-3","6-4","6-5","6-6","6-7","6-8","6-9",
                     "7-1","7-2","7-3","7-4","7-5","7-6","7-7","7-8","7-9",
                     "8-1","8-2","8-3","8-4","8-5","8-6","8-7","8-8","8-9",
                     "9-1","9-2","9-3","9-4","9-5","9-6","9-7","9-8","9-9",
                     "10-1","10-2","10-3","10-4","10-5","10-6","10-7","10-8","10-9",
                     "11-1","11-2","11-3","11-4","11-5","11-6","11-7","11-8","11-9"
        ]
        for items in mazes {
            Global.highScores[items] = UserDefaults.standard.integer(forKey: items)
        }

        if UserDefaults.standard.bool(forKey: "isWeaponsMember") {
            Global.isWeaponsMember = true
        }
        
    //    Global.isWeaponsMember = true //hack
        
        myGameOverView = GameOverView(backgroundColor: .white, buttonsColor: CustomColor.purple, colorScheme: .tier1, vc: self, bestScore: 10000, thisScore: 0)
        myGameOverView.bestScoreLabel.text = "BEST \(Global.highScores["1-1"]!)"
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(myGameOverView)
        myGameOverView.dropMaze.addTarget(self, action: #selector(ViewController.play(_:)), for: .touchUpInside)
        myGameOverView.instructions.addTarget(self, action: #selector(ViewController.runTutorial), for: .touchUpInside)
        
        if !UserDefaults.standard.bool(forKey: "LaunchedBefore99Mazes1") {
            UserDefaults.standard.set(true, forKey: "LaunchedBefore99Mazes1")
            runTutorial()
            
        } else {
            
          sceneView.session.run(configuration)
        }
    }
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidAppear(_ animated: Bool) {
 
    }
    
    
    var gun = SCNNode()
    var torus1 = SCNNode()
    var torus2 = SCNNode()
    var torus3 = SCNNode()
    var torus4 = SCNNode()
    var torus5 = SCNNode()
    var torus6 = SCNNode()
    var torus7 = SCNNode()
    var torus8 = SCNNode()
    var torus9 = SCNNode()
    var torus10 = SCNNode()
    var torusAll = [SCNNode]()
    var wrapper = SCNNode()
    var maze: String = ""
    let goblinSpeed : Double = 0.1
    @objc private func play(_ button: UIButton) {
        
        tier.frame = CGRect(x: CGFloat(Int(115*sw)), y: CGFloat(Int(27*sh)), width: CGFloat(Int(127*sw)), height: CGFloat(Int(30*sh)))
        tier.text = "TIER \(myGameOverView.currentDotIndex + 1)"
        tier.font = UIFont(name: "HelveticaNeue-Bold", size: 13*fontSizeMultiplier)
        tier.backgroundColor = .black
        tier.textColor = .white
        tier.textAlignment = .center
        tier.alpha = 1.0
        
        invisibleCover.isUserInteractionEnabled = false
        let startText = "FORCE TOUCH TO EXIT"
        ringLabel.frame = CGRect(x: CGFloat(Int(78*self.sw)), y: CGFloat(Int(613*self.sh)), width: CGFloat(Int(219*self.sw)), height: CGFloat(Int(30*self.sh)))
        ringLabel.frame.origin.y = CGFloat(Int(sh*617))
        ringLabel.backgroundColor = .black
        ringLabel.textColor = .white
        ringLabel.text = startText
        ringLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13*fontSizeMultiplier)
        ringLabel.textAlignment = .center
        ringLabel.alpha = 1.0
        collisionLabel.frame = CGRect(x: 0, y: 550, width: 375*sw, height: 100*sh)
        collisionLabel.text = ""
        collisionLabel.textAlignment = .center
        collisionLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        collisionLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        tier.text = "TIER \(myGameOverView.currentDotIndex + 1)"
        switch self.myGameOverView.myColorScheme! {
        case .tier1:
            maze = "1-1"
        case .tier2:
            maze = "2-1"
        case .tier3:
            maze = "3-1"
        case .tier4:
            maze = "4-1"
        case .tier5:
            maze = "5-1"
        case .tier6:
            maze = "6-1"
        case .tier7:
            maze = "7-1"
        case .tier8:
            maze = "8-1"
        case .tier9:
            maze = "9-1"
        case .tier10:
            maze = "10-1"
        case .tier11:
            maze = "11-1"
            
        }
        
        crosshairView.alpha = 0.0
        crosshairView.frame = CGRect(x: CGFloat(Int(sw*375/4)), y: CGFloat(Int(sh*667/4)), width: CGFloat(Int(sw*375/2)), height: CGFloat(Int(sh*667/2)))
        crosshairView.image = #imageLiteral(resourceName: "crosshair")
        sceneView.addSubview(crosshairView)
        
        self.startScene(myscene: maze)
        sceneView.scene.physicsWorld.contactDelegate = self
        
    }
    
    private func startScene(myscene: String) {
        points = 0
        press = DeepPressGestureRecognizer(target: self, action: #selector(ViewController.backFunc(_:)))
        sceneView.addGestureRecognizer(press)
        back.alpha = 1.0
        
        tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapFunc(_:)))
        
      //  sceneView.debugOptions = SCNDebugOptions.showPhysicsShapes //hack
        
        playerNode?.removeFromParentNode()
        
        level = myscene
        
        currentScene = SCNScene()
        currentScene = SCNScene(named: "art.scnassets/\(myscene).scn")!
        wrapper = currentScene.rootNode.childNode(withName: "empty", recursively: false)!
    

        sceneView.scene = currentScene
         wrapper.position = sceneView.pointOfView!.position
         wrapper.eulerAngles.y = sceneView.pointOfView!.eulerAngles.y
         sceneView.scene.rootNode.position = sceneView.pointOfView!.position
       
         sceneView.scene.rootNode.eulerAngles = SCNVector3(0,0,0)
        
        
        
        
        //make sure goblins have contactbitmask
        
        for child in wrapper.childNodes {
            for secondChild  in child.childNodes {
                if secondChild.name == "goblin" {
                  
                    secondChild.physicsBody?.categoryBitMask = CollisionTypes.monster.rawValue
                    secondChild.physicsBody?.collisionBitMask = CollisionTypes.fireball.rawValue
                }
            }
            if child.name == "gun" {
                for secondChild in child.childNodes {
                    secondChild.categoryBitMask = 256
                }
            }
        }
        
        sceneSetup()
        
    }
    
    private func sceneSetup() {
        
        nodeForGoblinToFace = SCNNode()
        playerNode = Player.node()
        playerNode!.position = SCNVector3(0,-3,-0.5)
        nodeForGoblinToFace.position = SCNVector3(0,-3,0)
       // playerNode!.eulerAngles = SCNVector3(0,0,0)
        playerNode!.addChildNode(nodeForGoblinToFace)
        Global.delay(bySeconds: 3.0) {
            self.isFirstInfraction = true
        }
        
        sceneView.pointOfView?.addChildNode(playerNode!)
        
        
        
        torus1 = wrapper.childNode(withName: "torus1", recursively: false)!
        torus2 = wrapper.childNode(withName: "torus2", recursively: false)!
        torus3 = wrapper.childNode(withName: "torus3", recursively: false)!
        torus4 = wrapper.childNode(withName: "torus4", recursively: false)!
        torus5 = wrapper.childNode(withName: "torus5", recursively: false)!
        torus6 = wrapper.childNode(withName: "torus6", recursively: false)!
        torus7 = wrapper.childNode(withName: "torus7", recursively: false)!
        torus8 = wrapper.childNode(withName: "torus8", recursively: false)!
        torus9 = wrapper.childNode(withName: "torus9", recursively: false)!
        torus10 = wrapper.childNode(withName: "torus10", recursively: false)!
        gun = wrapper.childNode(withName: "gun", recursively: false)!
//        gunPosition.append(gun.scale)
//        gunPosition.append(gun.position)
//        gunPosition.append(gun.eulerAngles)
      
        
        if !Global.isWeaponsMember {
            gun.removeFromParentNode()
        }
        
        torusAll = [
            torus1,
            torus2,
            torus3,
            torus4,
            torus5,
            torus6,
            torus7,
            torus8,
            torus9,
            torus10
        ]
        let action0 = SCNAction.repeat(SCNAction.rotate(by: .pi/2, around: SCNVector3(0, 0, 1), duration: 0), count: 1)
        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 3))
        for torus in torusAll {
            torus.runAction(action0)
            torus.runAction(action)
        }
        myGameOverView.removeFromSuperview()
        
        sceneView.addSubview(invisibleCover)
        sceneView.addSubview(back)
        //  sceneView.addSubview(tier)
        invisibleCover.addSubview(ringLabel)
        // sceneView.addSubview(collisionLabel)
        
       // pickUpGun() //hack
        
        
        
            Global.delay(bySeconds: 10.0) {
                
                self.tier.alpha = 0.0
                
            }
        
        
        switch level {
        case "2-1":
            
            let goblinChase1 = wrapper.childNode(withName: "monsterChase1", recursively: false)!
            let goblinChase2 = wrapper.childNode(withName: "monsterChase2", recursively: false)!
            let goblinChase3 = wrapper.childNode(withName: "monsterChase3", recursively: false)!
            chasingGoblins = [ goblinChase1, goblinChase2, goblinChase3 ]
            
            
            for goblin in self.chasingGoblins {
                goblin.constraints = [SCNBillboardConstraint()]
                
            }
            
            
        case "6-1","8-1","10-1","11-1":
            let goblinChase1 = wrapper.childNode(withName: "monsterChase1", recursively: false)!
            let goblinChase2 = wrapper.childNode(withName: "monsterChase2", recursively: false)!
            let goblinChase3 = wrapper.childNode(withName: "monsterChase3", recursively: false)!
            let goblinChase4 = wrapper.childNode(withName: "monsterChase4", recursively: false)!
            let goblinChase5 = wrapper.childNode(withName: "monsterChase5", recursively: false)!
            let goblinChase6 = wrapper.childNode(withName: "monsterChase6", recursively: false)!
            chasingGoblins = [ goblinChase1, goblinChase2, goblinChase3, goblinChase4, goblinChase5, goblinChase6 ]
            for goblin in self.chasingGoblins {
                goblin.constraints = [SCNBillboardConstraint()]
                
            }
        default:
            break
        }
        sceneView.addGestureRecognizer(tap)
        
        chasingTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.chasingFunc), userInfo: nil, repeats: true)
        
    }
    
    @objc private func backFunc(_ button: UIButton) {
        if isFirstBackFunc {
            isFirstBackFunc = false
            backToVC()
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if !myGameOverView.isDescendant(of: view) {
                backToVC()
            }
        }
    }
    
    private func backToVC() {
        print("!!!!!Done!!!!!")
        
        myGameOverView.frame.origin.x = -375*sw
        view.addSubview(myGameOverView)
        pause()
        UIView.animate(withDuration: 1.0) {
            
            self.myGameOverView.frame.origin.x = 0
            
        }
        Global.delay(bySeconds: 0.8, closure: {self.run()})
        sceneView.removeGestureRecognizer(tap)
        sceneView.removeGestureRecognizer(press)
        invisibleCover.removeFromSuperview()
        ringLabel.removeFromSuperview()
        back.removeFromSuperview()
        tier.removeFromSuperview()
        collisionLabel.removeFromSuperview()
        location.removeFromSuperview()
        gun.physicsBody?.collisionBitMask = CollisionTypes.weapon.rawValue
        ringsFound = 0
        chasingGoblins.removeAll()
        foundGun = false
        
        
        
        if let playerNode = playerNode {
            playerNode.removeFromParentNode()
        }
        
        timer1.invalidate()
        chasingTimer.invalidate()
        
        nodeForGoblinToFace.removeFromParentNode()
        isFirstInfraction = false
        isFirstRingTouch = true
        
        isFirstGunTouch = true
        
        myGameOverView.thisScoreLabel.text = "\(points)"
      
        if let globalHighScoresLevel = Global.highScores[level] {
     
        if points > globalHighScoresLevel {
            myGameOverView.bestScoreLabel.text = "BEST \(points)"
            Global.highScores[level] = points
    
            UserDefaults.standard.set(points, forKey: level)
        } else {
            myGameOverView.bestScoreLabel.text = "BEST \(globalHighScoresLevel)"
        }
        
        }
        if points == 10000 {
            myGameOverView.bestScoreLabel.text = "PERFECT!"
        }
        points = 0
        
                Global.delay(bySeconds: 1.0) {
            self.ringLabel.text = "FORCE TOUCH TO EXIT"
            self.ringLabel.frame = CGRect(x: 78*self.sw, y: 613*self.sh, width: 219*self.sw, height: 30*self.sh)
            self.isFirstBackFunc = true
            self.chaseTime = 0.0
            self.dropGun()
//            self.gunPosition.removeAll()
        }
        sceneView.removeGestureRecognizer(press)
        
    }
    
    var chaseTime = 0.0
    @objc private func chasingFunc() {
        
        switch level {
        case "2-1":
            if chaseTime == 0.0 {
                chaseTime = 21.0
            }
            
            
            for goblin in chasingGoblins {
                let playerNodePositionInWrapper = sceneView!.scene.rootNode.convertPosition(sceneView.pointOfView!.position, to: wrapper)
                let vect = SCNVector3(playerNodePositionInWrapper.x ,-3.0,playerNodePositionInWrapper.z)
                
                let _chaseTime = chaseTime + Double(arc4random_uniform(3)*5)
                
                let actionChase = SCNAction.move(to: vect, duration: _chaseTime)
                goblin.runAction(actionChase)
                
            }
            
        case "6-1":
            if chaseTime == 0.0 {
                chaseTime = 180.0
            }
            
            if chasingGoblins.count > 0 {
                let playerNodePositionInWrapper = sceneView!.scene.rootNode.convertPosition(sceneView.pointOfView!.position, to: wrapper)
                let vect = SCNVector3(playerNodePositionInWrapper.x ,-3.0,playerNodePositionInWrapper.z)
                
                let _chaseTime = chaseTime + Double(arc4random_uniform(3)*5)
                let actionChase = SCNAction.move(to: vect, duration: _chaseTime)
                chasingGoblins[0].runAction(actionChase)
            }
            if chasingGoblins.count > 1 {
                let playerNodePositionInWrapper = sceneView!.scene.rootNode.convertPosition(sceneView.pointOfView!.position, to: wrapper)
                let vect = SCNVector3(playerNodePositionInWrapper.x ,-3.0,playerNodePositionInWrapper.z)
                
                let _chaseTime = chaseTime + Double(arc4random_uniform(3)*5)
                let actionChase = SCNAction.move(to: vect, duration: _chaseTime)
                chasingGoblins[1].runAction(actionChase)
            }
            
            
        case "8-1","10-1","11-1":
            if chaseTime == 0.0 {
                chaseTime = 21.0
            }
            
            
            for goblin in chasingGoblins {
                let playerNodePositionInWrapper = sceneView!.scene.rootNode.convertPosition(sceneView.pointOfView!.position, to: wrapper)
                let vect = SCNVector3(playerNodePositionInWrapper.x ,-3.0,playerNodePositionInWrapper.z)
                
                let _chaseTime = chaseTime + Double(arc4random_uniform(3)*5)
                let actionChase = SCNAction.move(to: vect, duration: _chaseTime)
                goblin.runAction(actionChase)
            }
            
        default:
            break
        }
        if chaseTime > 3.0 {
            chaseTime -= 3.0
        }
    }
    
    
    private func changeLabelSize() {
        DispatchQueue.main.async {
            
            self.ringLabel.frame = CGRect(x: CGFloat(Int(275*self.sw/2)), y: CGFloat(Int(613*self.sh)), width: CGFloat(Int(100*self.sw)), height: CGFloat(Int(30*self.sh)))
        }
    }
    
    let torusNames = [
        "torus1",
        "torus2",
        "torus3",
        "torus4",
        "torus5",
        "torus6",
        "torus7",
        "torus8",
        "torus9",
        "torus10"
    ]
    
    var direction = SCNVector3()
    var direction2 = SCNVector3()
    
    
    
    @objc private func tapFunc(_ gesture: UITapGestureRecognizer) {
    
        var didNotGetRing = true
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let results: [SCNHitTestResult] = sceneView.hitTest(gesture.location(in: view), options: hitTestOptions)
        
        
        for result in results {
            
            if torusNames.contains(result.node.name!) {
                didNotGetRing = false
                let n = result.node
                if ringLabel.bounds.width > 130*sw {
                    changeLabelSize()
                }
                for i in 0...9 {
                    Global.delay(bySeconds: 0.1*Double(i)) {
                        self.points += 100
                        self.ringLabel.text = "\(self.points)"
                    }
                }
                
                
                let action = SCNAction.move(to: SCNVector3(n.position.x, n.position.y + 10, n.position.z), duration: 2.0)
                let action1 = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 0.5))
                
                result.node.runAction(action)
                result.node.runAction(action1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    result.node.removeFromParentNode()
                    if result.node.name! == "torus10" {
                        self.endGameSequence()
                    }
                    
                }
            }
        }
        
        if foundGun && didNotGetRing {
            //position gun
            
            if isGunReady {
                
                
                
                //         Global.delay(bySeconds: 0.2) {
                self.fireBeachBall()
                //}
                
            }
            
            
            
        }
        
    }
    
    let x:Float = 0.8
    let y:Float = 0.7
    let z:Float = 0.8
    private func fireBeachBall() {
        
        let pov = sceneView.pointOfView!
   
        let fireballNode = Fireball.node()
        
        fireballNode.name = "beachBall"
        
        fireballNode.scale = SCNVector3(2.5,2.5,2.5)
        if level == "1-1" {
            fireballNode.scale = SCNVector3(1.6,1.6,1.6)
        }
        fireballNode.position = SCNVector3(0.05,-0.05,-1)
            sceneView.pointOfView!.addChildNode(fireballNode)
        
        let currentFrame = sceneView.session.currentFrame!
        
        let n = SCNNode()
        
        sceneView.pointOfView!.addChildNode(n)
        
        
        
        var closeTranslation = matrix_identity_float4x4
        
        closeTranslation.columns.3.z = z
        closeTranslation.columns.3.x = x
        closeTranslation.columns.3.y = y
        
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -100.5
        
        
        n.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
     //   fireballNode.simdTransform = matrix_multiply(currentFrame.camera.transform, closeTranslation)
        n.simdTransform = matrix_multiply(pov.simdTransform, translation)
        
        direction = (n.position - fireballNode.position).normalized
        direction2 = (direction + SCNVector3(x: 0, y: 1, z: 0)).normalized
        
        var velocityMultiplier: Float = 30
        if level == "1-1" {
            velocityMultiplier = 60
        }
        

        fireballNode.physicsBody?.applyForce(direction * Fireball.INITIAL_VELOCITY * velocityMultiplier, asImpulse: true)

        fireballNode.physicsBody?.applyTorque(SCNVector4(x: 1, y: 0, z: 0, w: 8.0), asImpulse: true)
        n.removeFromParentNode()
        
        fireballNode.runAction(SCNAction.wait(duration: Fireball.TTL)) {
            fireballNode.removeFromParentNode()
        }
        
    }
    
    private func endGameSequence() {
//        let currentHighScore = Global.highScores[maze] ?? 0
//        if points > currentHighScore {
//            Global.highScores[maze] = points
//        }
        
        backToVC()
    }
    
    
    
    let tutorialView1 = UIImageView()
    let tutorialView2 = UIImageView()
    let tutorialView3 = UIImageView()
    let tutorialView4 = UIImageView()
    let tutorialView = UIView()
    var tutorialTap = UITapGestureRecognizer()
    var tutorialSwipeRight = UISwipeGestureRecognizer()
    var tutorialSwipeLeft = UISwipeGestureRecognizer()
    @objc private func runTutorial() {
        print("runtutorial")
        self.tutorialView.alpha = 1.0
        tutorialView1.image = #imageLiteral(resourceName: "Tutorial")
        tutorialView2.image = #imageLiteral(resourceName: "Tutorial 2")
        tutorialView3.image = #imageLiteral(resourceName: "Tutorial 3")
        tutorialView4.image = #imageLiteral(resourceName: "Tutorial 4")
        if UIScreen.main.bounds.width == 375 {
           
            var marginTop = CGFloat(0)
            if UIScreen.main.bounds.height > 667 {
                marginTop = CGFloat(Int(4*(UIScreen.main.bounds.height - 667)/5))
            }
            tutorialView1.frame = CGRect(x: 0, y: marginTop, width: 375, height: 667)
            tutorialView2.frame = CGRect(x: CGFloat(Int(375*sw)), y: marginTop, width: 375, height: 667)
            tutorialView3.frame = CGRect(x: CGFloat(Int(750*sw)), y: marginTop, width: 375, height: 667)
            tutorialView4.frame = CGRect(x: CGFloat(Int(1125*sw)), y: marginTop, width: 375, height: 667)
        } else {
            let margin = (UIScreen.main.bounds.width - 375)/2
            let marginTop = CGFloat(Int((UIScreen.main.bounds.height - 667)/2))
            tutorialView1.frame = CGRect(x: margin, y: marginTop, width: 375, height: 667)
            tutorialView2.frame = CGRect(x: CGFloat(Int(375*sw + margin)), y: marginTop, width: 375, height: 667)
            tutorialView3.frame = CGRect(x: CGFloat(Int(750*sw + margin)), y: marginTop, width: 375, height: 667)
            tutorialView4.frame = CGRect(x: CGFloat(Int(1125*sw + margin)), y: marginTop, width: 375, height: 667)
        }
        tutorialView.frame = CGRect(x: 0, y: 0, width: 375*4*sw, height: 667*sh)
        tutorialView.backgroundColor = .white
        view.addSubview(tutorialView)
        tutorialTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.pageForward(_:)))
        tutorialSwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.pageForward(_:)))
        tutorialSwipeLeft.direction = .left
        tutorialSwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.pageBackward(_:)))
        tutorialSwipeRight.direction = .right
        tutorialView.addSubview(tutorialView1)
        tutorialView.addSubview(tutorialView2)
        tutorialView.addSubview(tutorialView3)
        tutorialView.addSubview(tutorialView4)
        tutorialView.addGestureRecognizer(tutorialSwipeLeft)
        tutorialView.addGestureRecognizer(tutorialSwipeRight)
        tutorialView.addGestureRecognizer(tutorialTap)
        
        
        
    }
    
    @objc private func pageForward(_ gesture: UIGestureRecognizer) {
        if tutorialView.frame.origin.x <= -1100*sw {
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    self.sceneView.session.run(self.configuration)
                } else {
                    self.sceneView.session.run(self.configuration)
                }
            }
            
            UIView.animate(withDuration: 0.5) {
                self.tutorialView.alpha = 0.0
            }
            Global.delay(bySeconds: 0.6) {
                self.tutorialView.removeFromSuperview()
                self.tutorialView1.removeFromSuperview()
                self.tutorialView2.removeFromSuperview()
                self.tutorialView3.removeFromSuperview()
                self.tutorialView4.removeFromSuperview()
                
            }
        } else {
            
            UIView.animate(withDuration: 0.5) {
                self.tutorialView.frame.origin.x -= 375*self.sw
            }
        }
        
    }
    
    @objc private func pageBackward(_ gesture: UIGestureRecognizer) {
        
        if tutorialView.frame.origin.x > -100*sw {
            return
        } else {
            
            UIView.animate(withDuration: 0.5) {
                self.tutorialView.frame.origin.x += 375*self.sw
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        
         // sceneView.session.pause()
        
        
    }
    
    private func pickUpGun() {
        DispatchQueue.main.async {
            self.crosshairView.alpha = 1.0
        }
        
        gun.removeAllActions()
        foundGun = true
        gun.scale = SCNVector3(0.02,0.02,0.02)
        gun.position = SCNVector3(0.07 - 0.01,-0.12,-0.2)
        gun.eulerAngles = SCNVector3(-70.0.degreesToRadians,20.0.degreesToRadians,10.0.degreesToRadians)
        sceneView.pointOfView?.addChildNode(gun)
        gun.physicsBody?.collisionBitMask = 0
        
    }
    
    private func dropGun() {
        gun.removeAllActions()
//        wrapper.addChildNode(gun)
//        gun.scale = gunPosition[0]
//        gun.position = gunPosition[1]
//        gun.eulerAngles = gunPosition[2]
//        gunPosition.removeAll()
        crosshairView.alpha = 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    var isFirstGunTouch = true
    var isFirstInfraction = false
    var isFirstRingTouch = true
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let contactMask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        guard contact.nodeA.physicsBody != nil || contact.nodeB.physicsBody != nil else {return}

        
        //went through a wall
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.fence.rawValue)  {
            print("hit fence")
            DispatchQueue.main.async {
                self.collisionLabel.text = "hit fence :("
            }
            if isFirstInfraction {
                isFirstInfraction = false
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                DispatchQueue.main.async {
                    
                    if self.ringLabel.bounds.width > 130*self.sw {
                        self.changeLabelSize()
                    }
                }
                for i in 0...4 {
                    Global.delay(bySeconds: 0.3*Double(i)) {
                        self.points -= 100
                        self.ringLabel.text = "\(self.points)"
                    }
                }
                Global.delay(bySeconds: 5.0) {
                    self.isFirstInfraction = true
                }
            }
            
        }
        // touched a ring
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.coin.rawValue) {
            
            DispatchQueue.main.async {
                self.collisionLabel.text = "touched ring!!!"
            }
            if isFirstRingTouch {
                isFirstRingTouch = false
                Global.delay(bySeconds: 4.0) {
                    self.isFirstRingTouch = true
                }
                let n = contact.nodeA
                
                let action = SCNAction.move(to: SCNVector3(n.position.x, n.position.y + 10, n.position.z), duration: 2.0)
                let action1 = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 0.5))
                
                n.runAction(action)
                n.runAction(action1)
                DispatchQueue.main.async {
                 
                    if self.ringLabel.bounds.width > 130*self.sw {
                    self.changeLabelSize()
                }
                }
                for i in 0...9 {
                    Global.delay(bySeconds: 0.1*Double(i)) {
                        self.points += 100
                        self.ringLabel.text = "\(self.points)"
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    n.removeFromParentNode()
                    if n.name! == "torus10" {
                        self.endGameSequence()
                    }
                    
                }
            }
            
        }
        // touched gun
   
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.weapon.rawValue) && isFirstGunTouch {
        
            pickUpGun()
            playerNode!.physicsBody!.contactTestBitMask = CollisionTypes.coin.rawValue|CollisionTypes.monster.rawValue|CollisionTypes.fence.rawValue
            isFirstGunTouch = false
            DispatchQueue.main.async {
                self.collisionLabel.text = "touched gun!!!"
            }
            
            
            
            
            
            
        }
        // killed a monster
        if contactMask == (CollisionTypes.monster.rawValue | CollisionTypes.fireball.rawValue) {
         
            DispatchQueue.main.async {
                self.collisionLabel.text = "hit monster!!!"
            }
            //removeMonster
            if let nameA = contact.nodeA.name,
                let nameB = contact.nodeB.name {
                if nameA == "goblin" {
                    contact.nodeA.parent!.constraints = []
                    if chasingGoblins.contains(contact.nodeA) {
                        chasingGoblins.remove(at: chasingGoblins.index(of: contact.nodeA)!)
                    }
                    contact.nodeA.removeAllActions()
                    contact.nodeA.physicsBody?.applyForce(direction2 * Fireball.INITIAL_VELOCITY * 0.5, asImpulse: true)
                    contact.nodeA.physicsBody?.applyTorque(SCNVector4(x: 1, y: 0, z: 0, w: -6.0), asImpulse: true)
                    Global.delay(bySeconds: 3.0) {
                        contact.nodeA.removeFromParentNode()
                    }
                }
                if nameB == "goblin" {
                    contact.nodeB.parent!.constraints = []
                    if chasingGoblins.contains(contact.nodeB) {
                        chasingGoblins.remove(at: chasingGoblins.index(of: contact.nodeB)!)
                    }
                    contact.nodeB.removeAllActions()
                    contact.nodeB.physicsBody?.applyForce(direction2 * Fireball.INITIAL_VELOCITY * 0.5, asImpulse: true)
                    contact.nodeB.physicsBody?.applyTorque(SCNVector4(x: 1, y: 0, z: 0, w: -6.0), asImpulse: true)
                    Global.delay(bySeconds: 3.0) {
                        contact.nodeB.removeFromParentNode()
                    }
                }
            }
            
            // Fix: kill monster code
        }
        //monster hit you!
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.monster.rawValue) {
            
            DispatchQueue.main.async {
                self.collisionLabel.text = "monster hit you :("
            }
            if isFirstInfraction {
                //isFirstInfraction = false
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                DispatchQueue.main.async {
                    
                    if self.ringLabel.bounds.width > 130*self.sw {
                        self.changeLabelSize()
                    }
                }
                for i in 0...4 {
                    Global.delay(bySeconds: 0.3*Double(i)) {
                        self.points -= 100
                        self.ringLabel.text = "\(self.points)"
                    }
                }
                Global.delay(bySeconds: 5.0) {
                    self.isFirstInfraction = true
                }
            }
            //removeMonster
            if let nameA = contact.nodeA.name {
                if nameA == "goblin" {
                    
                    if chasingGoblins.contains(contact.nodeA) {
                        chasingGoblins.remove(at: chasingGoblins.index(of: contact.nodeA)!)
                    }
                    contact.nodeA.removeAllActions()
                    
                    contact.nodeA.removeFromParentNode()
                    
                }
                
                if let nameB = contact.nodeB.name {
                    if nameB == "goblin" {
                        
                        if chasingGoblins.contains(contact.nodeB) {
                            chasingGoblins.remove(at: chasingGoblins.index(of: contact.nodeB)!)
                        }
                        contact.nodeB.removeAllActions()
                        
                        contact.nodeB.removeFromParentNode()
                        
                    }
                }
            }
            
            
        }

    }
    func pause() {
        self.sceneView.session.pause()
    }
    func run() {
        sceneView.session.run(configuration, options: .resetTracking)
    }
}
