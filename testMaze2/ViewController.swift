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

class ViewController: UIViewController, ARSCNViewDelegate, BrothersUIAutoLayout {
    var tap = UITapGestureRecognizer()
    var ringsFound = 0
    var currentScene = SCNScene()
    // Create a new scene
    let sceneDict : [String:SCNScene] = [
        
        "maze1":SCNScene(named: "art.scnassets/maze1.scn")!,
        "maze2":SCNScene(named: "art.scnassets/maze2.scn")!,
        "maze3":SCNScene(named: "art.scnassets/maze3.scn")!,
        "maze4":SCNScene(named: "art.scnassets/maze4.scn")!
        
    ]
    let invisibleCover = UIView()
    let ringLabel = UILabel()
    var count = 0
    let back = UIButton()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        back.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        back.setTitle("X", for: .normal)
        back.titleLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: 80)
        back.addTarget(self, action: #selector(ViewController.backFunc(_:)), for: .touchUpInside)
        
        myGameOverView = GameOverView(backgroundColor: .white, buttonsColor: .red, colorScheme: .red, vc: self)
        
        invisibleCover.isUserInteractionEnabled = false
        
        ringLabel.frame = CGRect(x: 0, y: 667*sh/4, width: 375*sw, height: 667*sh/2)
        ringLabel.text = "1/10"
        ringLabel.textAlignment = .center
        ringLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 100)
        ringLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Set the scene to the view
        
    }
    
    var myGameOverView = GameOverView()
    //let myGameOverView = GameOverView(backgroundColor: .white, buttonsColor: .black, colorScheme: .red, vc: self)
    
    @objc private func backFunc(_ button: UIButton) {
        print("!!!!!Done!!!!!")
        myGameOverView.frame.origin.x = -375*sw
        view.addSubview(myGameOverView)
        
        UIView.animate(withDuration: 1.0) {
      //      self.sceneView.frame.origin.x = 375*self.sw
            self.myGameOverView.frame.origin.x = 0
        }
        Global.delay(bySeconds: 1.0) {
        self.sceneView.session.pause()
      //  self.sceneView.removeFromSuperview()
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
    
   

    @objc private func play(_ button: UIButton) {
        
        // create the alert
        let alert = UIAlertController(title: "Location", message: "Point camera forward towards a area (50 yards x 50 yards) with plenty space forward and to the left", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        let one = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
            _ -> Void in
            
            switch self.myGameOverView.myColorScheme! {
            case .lightBlue:
                self.currentScene = self.sceneDict["maze3"]!
                self.startScene(myscene: "maze3")
            case .white:
                self.currentScene = self.sceneDict["maze1"]!
                self.startScene(myscene: "maze1")
            case .teal:
                self.currentScene = self.sceneDict["maze4"]!
                self.startScene(myscene: "maze4")
            default:
                self.currentScene = self.sceneDict["maze2"]!
                self.startScene(myscene: "maze2")
            }
        
        
        
            }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(one)
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
        
        
        
        
        
    }
    
    
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
        // Set the view's delegate
        
        currentScene = sceneDict[myscene]!
        sceneView.scene = currentScene
        wrapper = currentScene.rootNode.childNode(withName: "empty", recursively: false)!
        wrapper.position = SCNVector3Make(0, 0, 0)
        
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
        print("toruscount:")
        print(torusAll.count)
        let action0 = SCNAction.repeat(SCNAction.rotate(by: .pi/2, around: SCNVector3(0, 0, 1), duration: 0), count: 1)!
        
        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 3))!
        
        for torus in torusAll {
            torus.runAction(action0)
            torus.runAction(action)
        }
        myGameOverView.removeFromSuperview()
        
        sceneView.addSubview(invisibleCover)
        sceneView.addSubview(back)
        
        
        
        
        
        
        
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
    
    @objc private func tapFunc(_ gesture: UITapGestureRecognizer) {
        print("tap")
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let results: [SCNHitTestResult] = sceneView.hitTest(gesture.location(in: view), options: hitTestOptions)
        print(results)
        
        for result in results {
            print(result.node.name!)
            if torusNames.contains(result.node.name!) {
                
                let n = result.node
                count += 1
                ringLabel.text = "\(count)/10"
                invisibleCover.addSubview(ringLabel)
                
                UIView.animate(withDuration: 1.0) {
                    self.ringLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 130)
                }
                
                let action = SCNAction.move(to: SCNVector3(n.position.x, n.position.y + 10, n.position.z), duration: 2.0)
                let action1 = SCNAction.repeatForever(SCNAction.rotate(by: .pi*2, around: SCNVector3(0, 1, 0), duration: 0.5))!
                
                result.node.runAction(action)
                result.node.runAction(action1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    result.node.removeFromParentNode()
                    self.ringLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 100)
                    self.ringLabel.removeFromSuperview()
                    
                }
            }
            
        }
    }
    
  
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(myGameOverView)
        myGameOverView.replay.addTarget(self, action: #selector(ViewController.play(_:)), for: .touchUpInside)
    }
    
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
}
