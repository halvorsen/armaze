//
//  GameOverView.swift
//  plinker pool?
//
//  Created by Aaron Halvorsen on 6/26/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class GameOverView: UIView, BrothersUIAutoLayout, DotTap {
    var activityView = UIActivityIndicatorView()
    
    @objc private func buyWeapons(_ button: UIButton) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Shoot Monsters", message: "Unlock weapons $0.99", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.purchaseWeapons()
            
        }
        let restoreAction = UIAlertAction(title: "Restore Purchase", style: UIAlertActionStyle.default) {
            UIAlertAction in
            
            SwiftyStoreKit.restorePurchases(atomically: true) { results in
                if results.restoreFailedPurchases.count > 0 {
                    print("Restore Failed: \(results.restoreFailedPurchases)")
                }
                else if results.restoredPurchases.count > 0 {
                    Global.isWeaponsMember = true
                    UserDefaults.standard.set(true, forKey: "isWeaponsMember")
                }
                else {
                    print("Nothing to Restore")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            print("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(restoreAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        viewC.present(alertController, animated: true, completion: nil)
    }
    
    private func purchaseWeapons(productId: String = "99Mazes.iap.unlockWeapons") {
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = self.center
        //Fix it iOS 11 moving purchase interaction to bottom of screen. Maybe move our activity view?
        activityView.startAnimating()
        activityView.alpha = 0.0
        self.addSubview(activityView)
        SwiftyStoreKit.purchaseProduct(productId) { result in
            switch result {
            case .success( _):
                Global.isWeaponsMember = true
                UserDefaults.standard.set(true, forKey: "isWeaponsMember")
                self.activityView.removeFromSuperview()
            case .error(let error):
                
                print("error: \(error)")
                print("Purchase Failed: \(error)")
                self.activityView.removeFromSuperview()
            }
        }
    }
    
    
    
    var tierLabel = UILabel()
    var myColorScheme:ColorScheme?
    var currentDotIndex = 0
    var dotsContainer = [Dot]()
    func tap(colorScheme: ColorScheme, myIndex: Int) {
        
        dotsContainer[currentDotIndex].shapeLayer.strokeColor = UIColor.clear.cgColor
        dotsContainer[myIndex].shapeLayer.strokeColor = UIColor.black.cgColor
        currentDotIndex = myIndex
        tierLabel.text = "TIER \(myIndex + 1)"
        

     
        //create delegate method to start scene and dismiss view
        
        UserDefaults.standard.set(colorScheme.rawValue, forKey: "colorScheme")
        CustomColor.changeCustomColor(colorScheme: colorScheme)
        myColorScheme = colorScheme
        thisScoreLabel.text = ""
        if let myColorScheme = myColorScheme {
            switch myColorScheme {
            case .tier1:
                bestScoreLabel.text = "BEST \(Global.highScores["1-1"]!)"
            case .tier2:
                bestScoreLabel.text = "BEST \(Global.highScores["2-1"]!)"
            case .tier3:
                bestScoreLabel.text = "BEST \(Global.highScores["3-1"]!)"
            case .tier4:
                bestScoreLabel.text = "BEST \(Global.highScores["4-1"]!)"
            case .tier5:
                bestScoreLabel.text = "BEST \(Global.highScores["5-1"]!)"
            case .tier6:
                bestScoreLabel.text = "BEST \(Global.highScores["6-1"]!)"
            case .tier7:
                bestScoreLabel.text = "BEST \(Global.highScores["7-1"]!)"
            case .tier8:
                bestScoreLabel.text = "BEST \(Global.highScores["8-1"]!)"
            case .tier9:
                bestScoreLabel.text = "BEST \(Global.highScores["9-1"]!)"
            case .tier10:
                bestScoreLabel.text = "BEST \(Global.highScores["10-1"]!)"
            case .tier11:
                bestScoreLabel.text = "BEST \(Global.highScores["11-1"]!)"
                
            }
        }
        
    }
    
    var (dropMaze,menu,instructions,weapon,extraLife) = (ReplayButton(), MenuButton(), GameCenterButton(), SubscribeToPremiumButton(), OneMoreLife())
    
    var viewC = UIViewController()
    init() {super.init(frame: .zero)}
    var (bestScoreLabel, thisScoreLabel) = (UILabel(),UILabel())
    
    init(backgroundColor: UIColor, buttonsColor: UIColor, colorScheme: ColorScheme, vc: UIViewController, bestScore: Int, thisScore: Int) {
        super.init(frame: .zero)
        viewC = vc
        self.frame = CGRect(x: 0, y: 0, width: 375*sw, height: 667*sh)
        self.frame.origin.x = 375*sw
        self.backgroundColor = backgroundColor
        myColorScheme = colorScheme
        dropMaze = ReplayButton(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 158*sh))
        //   menu = MenuButton(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 211*sh))
        instructions = GameCenterButton(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 211*sh))
        weapon = SubscribeToPremiumButton(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 264*sh))
        weapon.addTarget(self, action: #selector(GameOverView.buyWeapons(_:)), for: .touchUpInside)
        
        //      extraLife = OneMoreLife(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 317*sh))
        self.addSubview(dropMaze)
        
        self.addSubview(instructions)
        self.addSubview(weapon)
        
        
        
        UIView.animate(withDuration: 0.4) {
            self.frame.origin.x = 0
        }
        
        
        
        
        //add dots at bottom
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 606*sh, width: 375*sw, height: 45*sw))
        scrollView.contentSize = CGSize(width: 11*45*sw, height: scrollView.bounds.height)
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        let schemeArray: [ColorScheme] = [
            .tier1,
            .tier2,
            .tier3,
            .tier4,
            .tier5,
            .tier6,
            .tier7,
            .tier8,
            .tier9,
            .tier10,
            .tier11
        ]
        var count = 0
        for scheme in schemeArray {
            let myDot = Dot(color: CustomColor.colorDictionary[scheme]!.1, origin: CGPoint(x:45*CGFloat(count)*sw,y:0), colorScheme: scheme)
            scrollView.addSubview(myDot)
            myDot.tapDelegate = self
            dotsContainer.append(myDot)
            myDot.myIndex = count
            if count == 0 {
                myDot.shapeLayer.strokeColor = UIColor.black.cgColor
            }
            count += 1
        }
        self.addSubview(scrollView)
        scrollView.contentOffset.x = sw*22.5
        
        tierLabel.text = "TIER 1"
        tierLabel.frame = CGRect(x: 37*sw, y: 557*sh, width: 100*sw, height: 28*sh)
        tierLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 24*fontSizeMultiplier)
        
        addSubview(tierLabel)
        
        bestScoreLabel.frame = CGRect(x: 43*sw, y: 106*sh, width: 200*sw, height: 31*sh)
        bestScoreLabel.text = "BEST \(Global.topScore)"
        bestScoreLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 24*fontSizeMultiplier)
        bestScoreLabel.textColor = buttonsColor
        bestScoreLabel.addTextSpacing(spacing: 1.85*fontSizeMultiplier)
        self.addSubview(bestScoreLabel)
        
        thisScoreLabel.frame = CGRect(x: 43*sw, y: 29*sh, width: 200*sw, height: 84*sh)
        thisScoreLabel.text = "\(Global.points)"
        thisScoreLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 68*fontSizeMultiplier)
        thisScoreLabel.textColor = buttonsColor
        thisScoreLabel.addTextSpacing(spacing: 5.23*fontSizeMultiplier)
        self.addSubview(thisScoreLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

