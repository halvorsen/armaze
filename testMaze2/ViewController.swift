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

class ViewController: UIViewController, ARSCNViewDelegate, BrothersUIAutoLayout, SCNPhysicsContactDelegate {
    var tap = UITapGestureRecognizer()
    var press = DeepPressGestureRecognizer()
    var ringsFound = 0
    var currentScene = SCNScene()
    var playerNode:SCNNode?
    var foundGun = false
    var level = ""
    // Create a new scene
    let sceneDict : [String:SCNScene] = [
        
        "1-1":SCNScene(named: "art.scnassets/1-1.scn")!,
        "2-1":SCNScene(named: "art.scnassets/2-1.scn")!,
        "3-1":SCNScene(named: "art.scnassets/3-1.scn")!,
        "4-1":SCNScene(named: "art.scnassets/4-1.scn")!,
        "5-1":SCNScene(named: "art.scnassets/5-1.scn")!,
        "6-1":SCNScene(named: "art.scnassets/6-1.scn")!,
        "7-1":SCNScene(named: "art.scnassets/7-1.scn")!,
        "8-1":SCNScene(named: "art.scnassets/8-1.scn")!,
        "9-1":SCNScene(named: "art.scnassets/9-1.scn")!,
        "10-1":SCNScene(named: "art.scnassets/10-1.scn")!,
        "11-1":SCNScene(named: "art.scnassets/11-1.scn")!
        
    ]
    let invisibleCover = UIView()
    let ringLabel = UILabel()
    var points = 0
    let back = UILabel()
    let tier = UILabel()
    let collisionLabel = UILabel()
    let location = UILabel()
    @IBOutlet var sceneView: ARSCNView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Global.isWeaponsMember = true //hack
        
        foundGun = true //hack
        press = DeepPressGestureRecognizer(target: self, action: #selector(ViewController.backFunc(_:)))
        
        back.frame = CGRect(x: 69*sw, y: 613*sh, width: 219*sw, height: 30*sh)
        back.text = "FORCE TOUCH TO CLOSE"
        back.font = UIFont(name: "HelveticaNeue-Bold", size: 13*fontSizeMultiplier)
        back.backgroundColor = .black
        back.textColor = .white
        back.textAlignment = .center
        //   back.addTarget(self, action: #selector(ViewController.backFunc(_:)), for: .touchUpInside)
        tier.frame = CGRect(x: 115*sw, y: 27*sh, width: 127*sw, height: 30*sh)
        tier.text = "TIER \(myGameOverView.currentDotIndex + 1)"
        tier.font = UIFont(name: "HelveticaNeue-Bold", size: 13*fontSizeMultiplier)
        tier.backgroundColor = .black
        tier.textColor = .white
        tier.textAlignment = .center
        
        
        myGameOverView = GameOverView(backgroundColor: .white, buttonsColor: CustomColor.purple, colorScheme: .tier1, vc: self, bestScore: 10000, thisScore: 0)
        
        invisibleCover.isUserInteractionEnabled = false
        
        ringLabel.frame = CGRect(x: 0, y: 0, width: 375*sw, height: 100*sh)
        ringLabel.text = ""
        ringLabel.textAlignment = .center
        ringLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 100)
        ringLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        collisionLabel.frame = CGRect(x: 0, y: 550, width: 375*sw, height: 100*sh)
        collisionLabel.text = ""
        collisionLabel.textAlignment = .center
        collisionLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        collisionLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Set the scene to the view
        
    }
    
    var myGameOverView = GameOverView()
    //let myGameOverView = GameOverView(backgroundColor: .white, buttonsColor: .black, colorScheme: .red, vc: self)
    
    @objc private func backFunc(_ button: UIButton) {
        backToVC()
    }
    
    private func backToVC() {
        print("!!!!!Done!!!!!")
        myGameOverView.frame.origin.x = -375*sw
        view.addSubview(myGameOverView)
        myGameOverView.thisScoreLabel.text = "\(points)"
        if points > Global.highScores[level]! {
            Global.highScores[level] = points
            UserDefaults.standard.set(points, forKey: "level")
        }
        myGameOverView.bestScoreLabel.text = "\(Global.highScores[level]!)"
        if points == 10000 {
            myGameOverView.bestScoreLabel.text = "Perfect Score!"
        }
        UIView.animate(withDuration: 1.0) {
      
            self.myGameOverView.frame.origin.x = 0
        }
        Global.delay(bySeconds: 1.0) {
            self.sceneView.session.pause()

        }
        sceneView.removeGestureRecognizer(press)
        
    }
    //   var mycount = 0
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if let camPos = sceneView.pointOfView?.position {
            // let camPos = sceneView.scene.rootNode.convertPosition(rawCamPos, to: level.container)
            guard playerNode != nil else {return}
            // print("player node is not nil \(mycount)")
            //    mycount += 1
            playerNode!.position.x = camPos.x
            playerNode!.position.z = camPos.z
            playerNode!.position.y = camPos.y - 1
            
        }
        
    }
    
    
    
    
    
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //
    //                wrapper.position = SCNVector3Make(node.position.x, node.position.x, node.position.x)
    //
    //
    //
    //    }
    //
    //    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    //        wrapper.position = SCNVector3Make(node.position.x, node.position.x, node.position.x)
    //    }
    
    var maze: String = ""
    
    @objc private func play(_ button: UIButton) {
  
        
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
        
        self.currentScene = self.sceneDict[maze]!
        
        self.startScene(myscene: maze)
        sceneView.scene.physicsWorld.contactDelegate = self
        
        //            }
        
        //        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        //
        //        alert.addAction(one)
        //        // show the alert
        //        self.present(alert, animated: true, completion: nil)
        
        
        
        
        
        
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
    private func startScene(myscene: String) {
        
        tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapFunc(_:)))
        sceneView.addGestureRecognizer(tap)
        sceneView.addGestureRecognizer(press)
        let localCamPos = sceneView.scene.rootNode.position
        playerNode?.removeFromParentNode()
        playerNode = Player.node()
        playerNode!.position = localCamPos
        playerNode!.position.y = localCamPos.y - 1
        level = myscene
        
        currentScene = sceneDict[myscene]!
        sceneView.scene = currentScene
        wrapper = currentScene.rootNode.childNode(withName: "empty", recursively: false)!
        wrapper.position = SCNVector3Make(0, 0, 0)
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
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        
        
        let action0 = SCNAction.repeat(SCNAction.rotate(by: .pi/2, around: SCNVector3(0, 0, 1), duration: 0), count: 1)!
        
        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 3))!
        
        for torus in torusAll {
            torus.runAction(action0)
            torus.runAction(action)
        }
        myGameOverView.removeFromSuperview()
        
        sceneView.addSubview(invisibleCover)
        sceneView.addSubview(back)
        sceneView.addSubview(tier)
        invisibleCover.addSubview(ringLabel)
        sceneView.addSubview(collisionLabel)
        
        let crosshairView = UIImageView()
        crosshairView.frame = self.view.bounds
        crosshairView.image = #imageLiteral(resourceName: "crosshair")
        //sceneView.addSubview(crosshairView)
        crosshairView.alpha = 0.2
        
        Global.delay(bySeconds: 3.0) {
            
            UIView.animate(withDuration: 0.5){
                self.back.alpha = 0.0
                self.tier.alpha = 0.0
            }
            Global.delay(bySeconds: 0.5) {
                self.back.removeFromSuperview()
                self.tier.removeFromSuperview()
            }
            
        }
        pickUpGun() //hack
        
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
    var isGunReady = true
    @objc private func tapFunc(_ gesture: UITapGestureRecognizer) {
        print("tap")
        var didNotGetRing = true
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let results: [SCNHitTestResult] = sceneView.hitTest(gesture.location(in: view), options: hitTestOptions)
        print(results)
        
        for result in results {
            print(result.node.name!)
            if torusNames.contains(result.node.name!) {
                didNotGetRing = false
                let n = result.node
                for i in 0...9 {
                    Global.delay(bySeconds: 0.3*Double(i)) {
                        self.points += 100
                        self.ringLabel.text = "\(self.points)"
                    }
                }
                
                
                let action = SCNAction.move(to: SCNVector3(n.position.x, n.position.y + 10, n.position.z), duration: 2.0)
                let action1 = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 0.5))!
                
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
            print("position gun")
            if isGunReady {
                isGunReady = false
                gun.removeAllActions()
                
                let movePosRotationAction = SCNAction.rotateTo(x: CGFloat(-90.0.degreesToRadians), y: 0, z: 0, duration: 0.0)
                let moveNegRotationAction = SCNAction.rotateTo(x: CGFloat(-60.0.degreesToRadians), y: 0, z: CGFloat(30.0.degreesToRadians), duration: 0.5)
                if let rotationSequence = SCNAction.sequence([movePosRotationAction, moveNegRotationAction]) {
                    gun.runAction(rotationSequence)
                }
                let movePosAction = SCNAction.moveBy(x: -0.1, y: 0.2, z: 0.2, duration: 0.0)
                let moveNegAction = SCNAction.moveBy(x: 0.1, y: -0.2, z: -0.2, duration: 0.8)
                if let sequence = SCNAction.sequence([movePosAction, moveNegAction]) {
                    gun.runAction(sequence, completionHandler: {
                        
                        self.gun.position = SCNVector3(0.07 - 0.01,-0.25,-0.3)
                        self.gun.eulerAngles = SCNVector3(-60.0.degreesToRadians,0,30.0.degreesToRadians)
                        let movePosAction = SCNAction.moveBy(x: 0.02, y: 0, z: 0, duration: 0.7)
                        let moveNegAction = SCNAction.moveBy(x: -0.02, y: 0, z: 0, duration: 0.7)
                        let sequence = SCNAction.sequence([movePosAction, moveNegAction])
                        self.gun.runAction(SCNAction.repeatForever(sequence!)!)
                        self.isGunReady = true
                    })
                }
                
                
                //fire weapon
                
                //                if isPlaying, playerState != nil,
                //                    let pickup = playerState.pickup,
                //                    case .fireballPowerUp = pickup,
                //                    !wandIsRecharging {
                // spawn fireballs!
                let pov = sceneView.pointOfView!
                let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 0.5))!
                let fireballNode = Fireball.node()
                fireballNode.name = "beachBall"
                fireballNode.opacity = 0.0
                Global.delay(bySeconds: 0.02) {
                    fireballNode.opacity = 1.0
                }
                fireballNode.position = playerNode!.position
                //fireballNode.position.z -= 3
                //level!.container.addChildNode(fireballNode)
                
                self.sceneView.scene.rootNode.addChildNode(fireballNode)
                
                // we need camera direction vector
                // https://developer.apple.com/videos/play/wwdc2017/602/
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
                
                direction = (n.position - fireballNode.position).normalized
                direction2 = (direction + SCNVector3(x: 0, y: 1, z: 0)).normalized
                // fireball should come FROM THE TIP of the wand!
                if let wandNode = sceneView.pointOfView?.childNode(withName: Wand.WAND_NODE_NAME, recursively: false),
                    let tipNode = wandNode.childNode(withName: Wand.TIP_NODE_NAME, recursively: false) {
                    // all we need to do is to give the fireballNode the right starting position!!
                    // use same direction vector
                    
                    //   wandIsRecharging = true
                    wandNode.position.z = -0.2
                    wandNode.runAction(SCNAction.moveBy(x: 0, y: 0, z: -0.1, duration: Wand.RECHARGE_TIME))
                    tipNode.scale = SCNVector3(0,0,0)
                    //                        tipNode.runAction(SCNAction.scale(to: 1, duration: Wand.RECHARGE_TIME)) {
                    //                            self.wandIsRecharging = false
                    //                        }
                }
                
                fireballNode.physicsBody?.applyForce(direction * Fireball.INITIAL_VELOCITY * 500, asImpulse: true)
                fireballNode.physicsBody?.applyTorque(SCNVector4(x: 1, y: 0, z: 0, w: 8.0), asImpulse: true)
                n.removeFromParentNode()
                
                fireballNode.runAction(SCNAction.wait(duration: Fireball.TTL)) {
                    fireballNode.removeFromParentNode()
                }
            }
            //                    playerNode!.runAction(SCNAction.playAudio(Sound.fireball.source, waitForCompletion: false))
            
            return
            
        }
        
    }
    
    
    private func endGameSequence() {
        let currentHighScore = Global.highScores[maze] ?? 0
        if points > currentHighScore {
            Global.highScores[maze] = points
        }
        backToVC()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(myGameOverView)
        myGameOverView.dropMaze.addTarget(self, action: #selector(ViewController.play(_:)), for: .touchUpInside)
        myGameOverView.instructions.addTarget(self, action: #selector(ViewController.runTutorial), for: .touchUpInside)
        if UserDefaults.standard.bool(forKey: "is99MazesFirstLaunch") {
            UserDefaults.standard.set(true, forKey: "is99MazesFirstLaunch")
            runTutorial()
            
        }
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
        
        if tutorialView.frame.origin.x <= 100*sw {
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
        sceneView.session.pause()
    }
    
    private func pickUpGun() {
        gun.removeAllActions()
        //let carryNode = gun//Wand.wandNode()
        gun.scale = SCNVector3(0.01,0.01,0.01)
        gun.position = SCNVector3(0.07 - 0.01,-0.25,-0.3)
        gun.eulerAngles = SCNVector3(-60.0.degreesToRadians,0,30.0.degreesToRadians)
        
        let movePosAction = SCNAction.moveBy(x: 0.02, y: 0, z: 0, duration: 0.7)
        let moveNegAction = SCNAction.moveBy(x: -0.02, y: 0, z: 0, duration: 0.7)
        let sequence = SCNAction.sequence([movePosAction, moveNegAction])
        gun.runAction(SCNAction.repeatForever(sequence!)!)
        sceneView.pointOfView?.addChildNode(gun)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    //    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    //        let cameraPosition = sceneView.pointOfView?.position
    //    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - SCNPhysicsContactDelegate
    var isFirstGunTouch = true
    var isFirstInfraction = true
    var isFirstRingTouch = true
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("Contact")
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
                let action1 = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 0.5))!
                
                n.runAction(action)
                n.runAction(action1)
                
                for i in 0...9 {
                    Global.delay(bySeconds: 0.3*Double(i)) {
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
                    contact.nodeA.removeAllActions()
                    contact.nodeA.physicsBody?.applyForce(direction2 * Fireball.INITIAL_VELOCITY * 3, asImpulse: true)
                    contact.nodeA.physicsBody?.applyTorque(SCNVector4(x: 1, y: 0, z: 0, w: -8.0), asImpulse: true)
                    Global.delay(bySeconds: 3.0) {
                        contact.nodeA.removeFromParentNode()
                    }
                }
                if nameB == "goblin" {
                    print("goblin")
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
            if let nameA = contact.nodeA.name,
                let nameB = contact.nodeB.name {
                if nameA == "cone" {
                    contact.nodeA.removeFromParentNode()
                }
                if nameB == "cone" {
                    contact.nodeB.removeFromParentNode()
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
