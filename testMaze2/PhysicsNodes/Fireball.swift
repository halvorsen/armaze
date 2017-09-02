//
//  FireBall.swift
//  SuperMarioAR
//
//  Created by Bjarne Lundgren on 05/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit

class Fireball {
    static let TTL:TimeInterval = 5
    static let INITIAL_VELOCITY:Float = 10
    static let RADIUS:CGFloat =  1//Wand.TIP_RADIUS
    
    private static var sphere:SCNGeometry?
    
    class func node() -> SCNNode {
        
//        if sphere == nil {
//            //sphere = SCNSphere(radius: RADIUS)
//            //sphere!.materials = [Wand.sphereMaterial(lavaType: .fast)]
//
//
//            if let filePath = Bundle.main.path(forResource: "ball", ofType: "dae", inDirectory: "art.scnassets") {
//                // ReferenceNode path -> ReferenceNode URL
//                let referenceURL = NSURL(fileURLWithPath: filePath)
//
//
//                // Create reference node
//                let referenceNode = SCNReferenceNode(url: referenceURL as URL)
//                referenceNode?.load()
//                sphere = referenceNode!
//              //  scene.rootNode.addChildNode(referenceNode!)
//
//            }
//        }
        /*
         let fireSys = SCNParticleSystem(named: "FireSys.scnp", inDirectory: nil)!
         fireSys.emitterShape = sphere
         */
        var node = SCNNode()
        if let filePath = Bundle.main.path(forResource: "ball", ofType: "dae", inDirectory: "art.scnassets") {
            // ReferenceNode path -> ReferenceNode URL
            let referenceURL = NSURL(fileURLWithPath: filePath)
            
            
            // Create reference node
            let referenceNode = SCNReferenceNode(url: referenceURL as URL)
            referenceNode?.load()
            if let referenceNode = referenceNode {
                node = referenceNode
            }
            //  scene.rootNode.addChildNode(referenceNode!)
            
        }
        
        
        //let node = SCNNode()
        // node.addParticleSystem(fireSys)
        
        let body = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic,
                                  shape: nil)
        body.categoryBitMask = CollisionTypes.fireball.rawValue
        body.collisionBitMask = CollisionTypes.monster.rawValue
        body.contactTestBitMask = CollisionTypes.player.rawValue|CollisionTypes.monster.rawValue|CollisionTypes.coin.rawValue
        body.isAffectedByGravity = false
        body.mass = 100.0
        body.restitution = 0.5
        body.damping = 0.1
        body.friction = 0.8
        
        node.physicsBody = body
        
        return node
    }
}
