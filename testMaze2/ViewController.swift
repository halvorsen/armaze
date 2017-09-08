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
    var gunPosition = [SCNVector3]()
    let nodeForGoblinToFace = SCNNode()
    
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
        
        Global.isWeaponsMember = true //hack
        
        myGameOverView = GameOverView(backgroundColor: .white, buttonsColor: CustomColor.purple, colorScheme: .tier1, vc: self, bestScore: 10000, thisScore: 0)
        
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(myGameOverView)
        myGameOverView.dropMaze.addTarget(self, action: #selector(ViewController.play(_:)), for: .touchUpInside)
        myGameOverView.instructions.addTarget(self, action: #selector(ViewController.runTutorial), for: .touchUpInside)
        
        if !UserDefaults.standard.bool(forKey: "has99LaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "has99LaunchedBefore")
            runTutorial()
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @objc private func backFunc(_ button: UIButton) {
        if isFirstBackFunc {
            isFirstBackFunc = false
            backToVC()
        }
    }
    
    private func backToVC() {
        print("!!!!!Done!!!!!")
        sceneView.removeGestureRecognizer(tap)
        sceneView.removeGestureRecognizer(press)
        invisibleCover.removeFromSuperview()
        ringLabel.removeFromSuperview()
        back.removeFromSuperview()
        tier.removeFromSuperview()
        collisionLabel.removeFromSuperview()
        location.removeFromSuperview()
        
        ringsFound = 0
        chasingGoblins.removeAll()
        foundGun = false
        dropGun()
        gunPosition.removeAll()
        
        if let playerNode = playerNode {
            playerNode.removeFromParentNode()
        }
        
        timer1.invalidate()
        chasingTimer.invalidate()
        
        nodeForGoblinToFace.removeFromParentNode()
        isFirstInfraction = true
        isFirstRingTouch = true
        
        isFirstGunTouch = true
        myGameOverView.frame.origin.x = -375*sw
        view.addSubview(myGameOverView)
        
        myGameOverView.thisScoreLabel.text = "\(points)"
        if points > Global.highScores[level]! {
            Global.highScores[level] = points
            UserDefaults.standard.set(points, forKey: level)
        }
        myGameOverView.bestScoreLabel.text = "BEST \(Global.highScores[level]!)"
        if points == 10000 {
            myGameOverView.bestScoreLabel.text = "Perfect Score!"
        }
        points = 0
        
        UIView.animate(withDuration: 1.0) {
            
            self.myGameOverView.frame.origin.x = 0
        }
        Global.delay(bySeconds: 1.0) {
            self.ringLabel.text = "Analyzing-Pan Camera Around"
            //       self.sceneView.session.pause()
            self.isFirstBackFunc = true
            self.chaseTime = 0.0
        }
        sceneView.removeGestureRecognizer(press)
        
    }
    var chaseTime = 0.0
    @objc private func chasingFunc() {
        guard let camPos = sceneView.pointOfView?.position else {return}
        
        guard playerNode != nil else {return}
        
        playerNode!.position.x = camPos.x
        playerNode!.position.z = camPos.z
        playerNode!.position.y = camPos.y - 1
        
        switch level {
        case "2-1":
            if chaseTime == 0.0 {
                chaseTime = 21.0
            }
            let vect = SCNVector3(playerNode!.position.x,-3.0,playerNode!.position.z)
            let vectMag = Double(vect.magnitude)
            let actionChase = SCNAction.move(to: vect, duration: chaseTime)
            
            
            
            for goblin in chasingGoblins {
                
                goblin.runAction(actionChase)
                
            }
            
        case "6-1":
            if chaseTime == 0.0 {
                chaseTime = 180.0
            }
            let vect = SCNVector3(playerNode!.position.x,-3.0,playerNode!.position.z)
            let vectMag = Double(vect.magnitude)
            let actionChase = SCNAction.move(to: vect, duration: chaseTime)
            
            
            if chasingGoblins.count > 0 {
                chasingGoblins[0].runAction(actionChase)
            }
            if chasingGoblins.count > 1 {
                chasingGoblins[1].runAction(actionChase)
            }
            
            
        case "8-1","10-1","11-1":
            if chaseTime == 0.0 {
                chaseTime = 21.0
            }
            let vect = SCNVector3(playerNode!.position.x,-3.0,playerNode!.position.z)
            let vectMag = Double(vect.magnitude)
            let actionChase = SCNAction.move(to: vect, duration: chaseTime)
            
            
            for goblin in chasingGoblins {
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
        
        ringLabel.frame = CGRect(x: 115*sw, y: 613*sh, width: 127*sw, height: 30*sh)
        
    }
    
    var maze: String = ""
    let goblinSpeed : Double = 0.1
    @objc private func play(_ button: UIButton) {
        
        //        back.frame = CGRect(x: 69*sw, y: 27*sh, width: 219*sw, height: 30*sh)
        //        back.text = "FORCE TOUCH TO CLOSE"
        //        back.font = UIFont(name: "HelveticaNeue-Bold", size: 13*fontSizeMultiplier)
        //        back.backgroundColor = .black
        //        back.textColor = .white
        //        back.textAlignment = .center
        
        tier.frame = CGRect(x: 115*sw, y: 27*sh, width: 127*sw, height: 30*sh)
        tier.text = "TIER \(myGameOverView.currentDotIndex + 1)"
        tier.font = UIFont(name: "HelveticaNeue-Bold", size: 13*fontSizeMultiplier)
        tier.backgroundColor = .black
        tier.textColor = .white
        tier.textAlignment = .center
        tier.alpha = 1.0
        
        invisibleCover.isUserInteractionEnabled = false
        
        ringLabel.frame = CGRect(x: 67*sw, y: 613*sh, width: 219*sw, height: 30*sh)
        ringLabel.frame.origin.y = sh*617
        ringLabel.backgroundColor = .black
        ringLabel.text = "Analyzing-Pan Camera Around"
        ringLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13*fontSizeMultiplier)
        ringLabel.textAlignment = .center
        
        ringLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
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
        
        
        crosshairView.frame = self.view.bounds
        crosshairView.image = #imageLiteral(resourceName: "crosshair")
        sceneView.addSubview(crosshairView)
        
        //   self.currentScene = self.sceneDict[maze]!
        
        self.startScene(myscene: maze)
        sceneView.scene.physicsWorld.contactDelegate = self
        
    }
    
    var light = SCNNode()
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
    private func startScene(myscene: String) {
        
        press = DeepPressGestureRecognizer(target: self, action: #selector(ViewController.backFunc(_:)))
        sceneView.addGestureRecognizer(press)
        back.alpha = 1.0
        
        tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapFunc(_:)))
        
        //potential problem???
        let localCamPos = sceneView.scene.rootNode.position
        
        playerNode?.removeFromParentNode()
        playerNode = Player.node()
        playerNode!.position = localCamPos
        playerNode!.position.y = localCamPos.y - 1
        nodeForGoblinToFace.position = SCNVector3(0,-3,0)
        
        playerNode!.addChildNode(nodeForGoblinToFace)
        level = myscene
        currentScene = SCNScene()
        currentScene = SCNScene(named: "art.scnassets/\(myscene).scn")!
        
        sceneView.scene = currentScene
        
        sceneSetup()
    }
    
    private func sceneSetup() {
        wrapper = currentScene.rootNode.childNode(withName: "empty", recursively: false)!
        light = currentScene.rootNode.childNode(withName: "directional", recursively: false)!
        //potential problem???
        wrapper.position = sceneView.pointOfView!.position
        
        wrapper.addChildNode(playerNode!)
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
        gunPosition.append(gun.scale)
        gunPosition.append(gun.position)
        gunPosition.append(gun.eulerAngles)
        
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
        
        //potential problem area?
        if isSessionFirstRunning {
            let configuration = ARWorldTrackingConfiguration()
            
            sceneView.session.run(configuration)
        }
        
        wrapper.position = sceneView.pointOfView!.position
        wrapper.eulerAngles.y = sceneView.pointOfView!.eulerAngles.y
        
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
        sceneView.addSubview(collisionLabel)
       
      //  pickUpGun() //hack
        
        
        if level == "1-1" {
            Global.delay(bySeconds: 10.0) {
                
                self.ringLabel.text = "FORCE TOUCH TO CLOSE"
                self.tier.alpha = 0.0
                //  self.ringLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 50)
                
            }
        } else {
            Global.delay(bySeconds: 5.0) {
                
                self.ringLabel.text = "FORCE TOUCH TO CLOSE"
                self.tier.alpha = 0.0
                //  self.ringLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 50)
                
            }
        }
        print("level: \(level)")
        switch level {
        case "2-1":
            
            let goblinChase1 = wrapper.childNode(withName: "monsterChase1", recursively: false)!
            let goblinChase2 = wrapper.childNode(withName: "monsterChase2", recursively: false)!
            let goblinChase3 = wrapper.childNode(withName: "monsterChase3", recursively: false)!
            chasingGoblins = [ goblinChase1, goblinChase2, goblinChase3 ]
            timer1 = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: {_ in
               
                for goblin in self.chasingGoblins {
                    
                    goblin.look(at: self.nodeForGoblinToFace.position - goblin.position)
                    
                }
            })
            
        case "6-1","8-1","10-1","11-1":
            let goblinChase1 = wrapper.childNode(withName: "monsterChase1", recursively: false)!
            let goblinChase2 = wrapper.childNode(withName: "monsterChase2", recursively: false)!
            let goblinChase3 = wrapper.childNode(withName: "monsterChase3", recursively: false)!
            let goblinChase4 = wrapper.childNode(withName: "monsterChase4", recursively: false)!
            let goblinChase5 = wrapper.childNode(withName: "monsterChase5", recursively: false)!
            let goblinChase6 = wrapper.childNode(withName: "monsterChase6", recursively: false)!
            chasingGoblins = [ goblinChase1, goblinChase2, goblinChase3, goblinChase4, goblinChase5, goblinChase6 ]
            timer1 = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: {_ in
               
                for goblin in self.chasingGoblins {
                    
                    goblin.look(at: self.nodeForGoblinToFace.position - goblin.position)
                    
                }
            })
        default:
            break
        }
        sceneView.addGestureRecognizer(tap)
        
        chasingTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.chasingFunc), userInfo: nil, repeats: true)
        
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
        print("tap")
        var didNotGetRing = true
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let results: [SCNHitTestResult] = sceneView.hitTest(gesture.location(in: view), options: hitTestOptions)
        print(results)
        
        for result in results {
            
            if torusNames.contains(result.node.name!) {
                didNotGetRing = false
                let n = result.node
                if ringLabel.bounds.width > 130*sw {
                    changeLabelSize()
                }
                for i in 0...9 {
                    Global.delay(bySeconds: 0.3*Double(i)) {
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
                //  isGunReady = false
                //    gun.removeAllActions()
                //  crosshairView.alpha = 0.2
                //  Global.delay(bySeconds: 0.2, closure: {self.crosshairView.alpha = 0.0})
                //                let movePosRotationAction = SCNAction.rotateTo(x: CGFloat(-90.0.degreesToRadians), y: 0, z: 0, duration: 0.2)
                //                let moveNegRotationAction = SCNAction.rotateTo(x: CGFloat(-60.0.degreesToRadians), y: 0, z: CGFloat(30.0.degreesToRadians), duration: 0.5)
                //                let rotationSequence = SCNAction.sequence([movePosRotationAction, moveNegRotationAction])
                //                    gun.runAction(rotationSequence)
                //
                //                let movePosAction = SCNAction.moveBy(x: -0.1, y: 0.2, z: 0.2, duration: 0.2)
                //                let moveNegAction = SCNAction.moveBy(x: 0.1, y: -0.2, z: -0.2, duration: 0.8)
                //                let sequence = SCNAction.sequence([movePosAction, moveNegAction])
                //                    gun.runAction(sequence, completionHandler: {
                //
                //                        self.gun.position = SCNVector3(0.07 - 0.01,-0.25,-0.3)
                //                        self.gun.eulerAngles = SCNVector3(-60.0.degreesToRadians,0,30.0.degreesToRadians)
                //                        let movePosAction = SCNAction.moveBy(x: 0.02, y: 0, z: 0, duration: 0.7)
                //                        let moveNegAction = SCNAction.moveBy(x: -0.02, y: 0, z: 0, duration: 0.7)
                //                        let sequence = SCNAction.sequence([movePosAction, moveNegAction])
                //                        self.gun.runAction(SCNAction.repeatForever(sequence))
                //                        self.isGunReady = true
                //                    })
                //
                
                Global.delay(bySeconds: 0.2) {
                    self.fireBeachBall()
                }
                
            }
            
            
            
        }
        
    }
    
    private func fireBeachBall() {
        
        let pov = sceneView.pointOfView!
        // let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 0.5))
        let fireballNode = Fireball.node()
        fireballNode.name = "beachBall"
        
        fireballNode.opacity = 1.0
        
        fireballNode.scale = SCNVector3(0.5,0.5,0.5)   //playerNode!.position
        // let gunPoint = gun.childNode(withName: "point", recursively: false)!
        sceneView.scene.rootNode.addChildNode(fireballNode)
        //fireballNode.runAction(SCNAction.move(by: SCNVector3(0.5,0.5,-0.2), duration: 0.0))
        let currentFrame = sceneView.session.currentFrame!
        
        let n = SCNNode()
        sceneView.scene.rootNode.addChildNode(n)
        
        var closeTranslation = matrix_identity_float4x4
        closeTranslation.columns.3.z = -0.5
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        n.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        fireballNode.simdTransform = matrix_multiply(currentFrame.camera.transform, closeTranslation)
        n.simdTransform = matrix_multiply(pov.simdTransform, translation)
        let gunPoint = gun.childNode(withName: "point", recursively: false)!
        
        direction = (n.position - fireballNode.position).normalized
        direction2 = (direction + SCNVector3(x: 0, y: 1, z: 0)).normalized
        
        fireballNode.position = gun.convertPosition(gunPoint.position, to: sceneView.scene.rootNode)
        
        fireballNode.physicsBody?.applyForce(direction * Fireball.INITIAL_VELOCITY * 250, asImpulse: true)
        fireballNode.physicsBody?.applyTorque(SCNVector4(x: 1, y: 0, z: 0, w: 8.0), asImpulse: true)
        n.removeFromParentNode()
        
        fireballNode.runAction(SCNAction.wait(duration: Fireball.TTL)) {
            fireballNode.removeFromParentNode()
        }
        
    }
    
    private func endGameSequence() {
        let currentHighScore = Global.highScores[maze] ?? 0
        if points > currentHighScore {
            Global.highScores[maze] = points
        }
        
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
        
        tutorialView1.image = #imageLiteral(resourceName: "Tutorial")
        tutorialView2.image = #imageLiteral(resourceName: "Tutorial 2")
        tutorialView3.image = #imageLiteral(resourceName: "Tutorial 3")
        tutorialView4.image = #imageLiteral(resourceName: "Tutorial 4")
        if UIScreen.main.bounds.width == 375 {
            tutorialView1.frame = CGRect(x: 0, y: 0, width: 375*sw, height: 667*sh)
            tutorialView2.frame = CGRect(x: 375*sw, y: 0, width: 375*sw, height: 667*sh)
            tutorialView3.frame = CGRect(x: 750*sw, y: 0, width: 375*sw, height: 667*sh)
            tutorialView4.frame = CGRect(x: 1125*sw, y: 0, width: 375*sw, height: 667*sh)
        } else {
            let margin = (UIScreen.main.bounds.width - 375)/2
            tutorialView1.frame = CGRect(x: margin, y: 0, width: 375*sw, height: 667*sh)
            tutorialView2.frame = CGRect(x: 375*sw + margin, y: 0, width: 375, height: 667*sh)
            tutorialView3.frame = CGRect(x: 750*sw + margin, y: 0, width: 375, height: 667*sh)
            tutorialView4.frame = CGRect(x: 1125*sw + margin, y: 0, width: 375, height: 667*sh)
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
        if tutorialView.frame.origin.x >= 1100*sw {
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    //access granted, do nothing
                } else {
                    
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
        print("tutorial frame origin x: \(tutorialView.frame.origin.x)")
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
        
        //  sceneView.session.pause()
        
        
    }
    
    private func pickUpGun() {
        gun.removeAllActions()
        
        gun.scale = SCNVector3(0.01,0.01,0.01)
        gun.position = SCNVector3(0.07 - 0.01,-0.15,-0.2)
        gun.eulerAngles = SCNVector3(-70.0.degreesToRadians,10.0.degreesToRadians,10.0.degreesToRadians)
        
        //        gun.scale = SCNVector3(0.01,0.01,0.01)
        //        gun.position = SCNVector3(0.07 - 0.01,-0.25,-0.3)
        //        gun.eulerAngles = SCNVector3(-60.0.degreesToRadians,0,30.0.degreesToRadians)
        
        //        let movePosAction = SCNAction.moveBy(x: 0.02, y: 0, z: 0, duration: 0.7)
        //        let moveNegAction = SCNAction.moveBy(x: -0.02, y: 0, z: 0, duration: 0.7)
        //        let sequence = SCNAction.sequence([movePosAction, moveNegAction])
        //        gun.runAction(SCNAction.repeatForever(sequence))
        sceneView.pointOfView?.addChildNode(gun)
        
    }
    
    private func dropGun() {
        gun.removeAllActions()
        wrapper.addChildNode(gun)
        print("gunposition again")
        print(gunPosition)
        gun.scale = gunPosition[0]
        gun.position = gunPosition[1]
        gun.eulerAngles = gunPosition[2]
        gunPosition.removeAll()
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
    var isFirstInfraction = true
    var isFirstRingTouch = true
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let contactMask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        guard contact.nodeA.physicsBody != nil || contact.nodeB.physicsBody != nil else {return}
        print("nodeA: \(contact.nodeA.physicsBody!.categoryBitMask)")
        print("nodeB: \(contact.nodeB.physicsBody!.categoryBitMask)")
        
        //went through a wall
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.fence.rawValue)  {
            print("hit fence :(")
            DispatchQueue.main.async {
                self.collisionLabel.text = "hit fence :("
            }
            if isFirstInfraction {
                isFirstInfraction = false
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                if ringLabel.bounds.width > 130*sw {
                    changeLabelSize()
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
            print("touched ring!!!")
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
                if ringLabel.bounds.width > 130*sw {
                    changeLabelSize()
                }
                for i in 0...9 {
                    Global.delay(bySeconds: 0.3*Double(i)) {
                        self.points += 100
                        self.ringLabel.text = "\(self.points)"
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    n.removeFromParentNode()
                    if n.name! == "torus10" {
                        self.endGameSequence()
                    }
                    
                }
            }
            
        }
        // touched gun
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.weapon.rawValue) && isFirstGunTouch {
            print("touched gun!!!")
            isFirstGunTouch = false
            DispatchQueue.main.async {
                self.collisionLabel.text = "touched gun!!!"
            }
            foundGun = true
            pickUpGun()
            
            
            
            
        }
        // killed a monster
        if contactMask == (CollisionTypes.monster.rawValue | CollisionTypes.fireball.rawValue) {
            print("hit monster!!!")
            DispatchQueue.main.async {
                self.collisionLabel.text = "hit monster!!!"
            }
            //removeMonster
            if let nameA = contact.nodeA.name,
                let nameB = contact.nodeB.name {
                if nameA == "goblin" {
                    print("goblin")
                    if chasingGoblins.contains(contact.nodeA) {
                        chasingGoblins.remove(at: chasingGoblins.index(of: contact.nodeA)!)
                    }
                    contact.nodeA.removeAllActions()
                    contact.nodeA.physicsBody?.applyForce(direction2 * Fireball.INITIAL_VELOCITY * 3, asImpulse: true)
                    contact.nodeA.physicsBody?.applyTorque(SCNVector4(x: 1, y: 0, z: 0, w: -8.0), asImpulse: true)
                    Global.delay(bySeconds: 3.0) {
                        contact.nodeA.removeFromParentNode()
                    }
                }
                if nameB == "goblin" {
                    print("goblin")
                    if chasingGoblins.contains(contact.nodeB) {
                        chasingGoblins.remove(at: chasingGoblins.index(of: contact.nodeB)!)
                    }
                    contact.nodeB.removeAllActions()
                    contact.nodeB.physicsBody?.applyForce(direction2 * Fireball.INITIAL_VELOCITY * 10, asImpulse: true)
                    contact.nodeB.physicsBody?.applyTorque(SCNVector4(x: 1, y: 0, z: 0, w: -8.0), asImpulse: true)
                    Global.delay(bySeconds: 3.0) {
                        contact.nodeB.removeFromParentNode()
                    }
                }
            }
            
            // Fix: kill monster code
        }
        //monster hit you!
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.monster.rawValue) {
            print("monster hit you!!!")
            DispatchQueue.main.async {
                self.collisionLabel.text = "monster hit you :("
            }
            if isFirstInfraction {
                isFirstInfraction = false
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                if ringLabel.bounds.width > 130*sw {
                    changeLabelSize()
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
        //        if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.coin.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.fireball.rawValue {
        //            print("fireball Hit ring")
        //            DispatchQueue.main.async {
        //            self.collisionLabel.text = "Fireball hit ring"
        //            }
        //        }
        
    }
}
