//
//  GameOverView.swift
//  plinker pool?
//
//  Created by Aaron Halvorsen on 6/26/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit
//import SwiftyStoreKit



class GameOverView: UIView, BrothersUIAutoLayout, DotTap {
    var activityView = UIActivityIndicatorView()
    
//    private func colorThemesFunc() {
//        // Create the alert controller
//        let alertController = UIAlertController(title: "Color Themes", message: "Unlock all color themes $2.99", preferredStyle: .alert)
//
//        // Create the actions
//        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
//            UIAlertAction in
//            self.purchaseColorThemes()
//
//        }
//        let restoreAction = UIAlertAction(title: "Restore Purchase", style: UIAlertActionStyle.default) {
//            UIAlertAction in
//
//            SwiftyStoreKit.restorePurchases(atomically: true) { results in
//                if results.restoreFailedPurchases.count > 0 {
//                    print("Restore Failed: \(results.restoreFailedPurchases)")
//                }
//                else if results.restoredPurchases.count > 0 {
//                    Global.isColorThemes = true
//                    UserDefaults.standard.set(true, forKey: "isColorThemes")
//                }
//                else {
//                    print("Nothing to Restore")
//                }
//            }
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
//            UIAlertAction in
//            print("Cancel Pressed")
//        }
//
//        // Add the actions
//        alertController.addAction(okAction)
//        alertController.addAction(restoreAction)
//        alertController.addAction(cancelAction)
//
//        // Present the controller
//        viewC.present(alertController, animated: true, completion: nil)
//    }
    
//    private func purchaseColorThemes(productId: String = "plinkerPool.iap.colorThemes") {
//       
//        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
//        activityView.center = self.center
//        activityView.startAnimating()
//        activityView.alpha = 0.0
//        self.addSubview(activityView)
//        SwiftyStoreKit.purchaseProduct(productId) { result in
//            switch result {
//            case .success( _):
//                Global.isColorThemes = true
//                UserDefaults.standard.set(true, forKey: "isColorThemes")
//                self.activityView.removeFromSuperview()
//            case .error(let error):
//                
//                print("error: \(error)")
//                print("Purchase Failed: \(error)")
//                self.activityView.removeFromSuperview()
//            }
//        }
//    }
    
    
    
    var tierLabel = UILabel()
    var myColorScheme:ColorScheme?
    var currentDotIndex = 0
    var dotsContainer = [Dot]()
    func tap(colorScheme: ColorScheme, myIndex: Int) {
        
        dotsContainer[currentDotIndex].shapeLayer.strokeColor = UIColor.clear.cgColor
        dotsContainer[myIndex].shapeLayer.strokeColor = UIColor.black.cgColor
        currentDotIndex = myIndex
        tierLabel.text = "TIER \(myIndex + 1)"
        
        //old tap dot to get into a maze, change is above to just change the tier label and queue up the correct maze
        if Global.isColorThemes == true || colorScheme.rawValue == 0  || colorScheme.rawValue == 1 || colorScheme.rawValue == 5 || true { //hack
            
            //maze from raw-colorscheme value
            let myInt = colorScheme.rawValue
            let maze = "maze\(myInt)"
            //create delegate method to start scene and dismiss view
            
        UserDefaults.standard.set(colorScheme.rawValue, forKey: "colorScheme")
        CustomColor.changeCustomColor(colorScheme: colorScheme)
        myColorScheme = colorScheme
 
//        self.gameCenter.backgroundColor = CustomColor.color2
//        self.extraLife.layer.borderColor = CustomColor.color2.cgColor
//        self.extraLife.setTitleColor(CustomColor.color2, for: .normal)
//        self.noAds.backgroundColor = CustomColor.color2
//        self.replay.backgroundColor = CustomColor.color2
        }
        
    }

    var (replay,menu,gameCenter,noAds,extraLife) = (ReplayButton(), MenuButton(), GameCenterButton(), SubscribeToPremiumButton(), OneMoreLife())
    
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
        replay = ReplayButton(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 158*sh))
     //   menu = MenuButton(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 211*sh))
        gameCenter = GameCenterButton(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 211*sh))
        noAds = SubscribeToPremiumButton(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 264*sh))
  //      extraLife = OneMoreLife(color: buttonsColor, origin: CGPoint(x: 42*sw, y: 317*sh))
        self.addSubview(replay)
   
        self.addSubview(gameCenter)
        self.addSubview(noAds)

  

        UIView.animate(withDuration: 0.4) {
            self.frame.origin.x = 0
        }
        
        Global.delay(bySeconds: 0.7) {
            self.extraLife.setTitle("ONE MORE LIFE  4", for: .normal)
            Global.delay(bySeconds: 0.7) {
                self.extraLife.setTitle("ONE MORE LIFE  3", for: .normal)
                Global.delay(bySeconds: 0.7) {
                    self.extraLife.setTitle("ONE MORE LIFE  2", for: .normal)
                    Global.delay(bySeconds: 0.7) {
                        self.extraLife.setTitle("ONE MORE LIFE  1", for: .normal)
                        Global.delay(bySeconds: 0.7) {
                            self.extraLife.removeFromSuperview()
                            
                        }
                    }
                }
            }
        }
        
        let skin1Label = UILabel(frame: CGRect(x: 42*sw, y: 418*sh, width: 350*sw, height: 24*sh))
        let skin2Label = UILabel(frame: CGRect(x: 42*sw, y: 505*sh, width: 350*sw, height: 24*sh))
        skin1Label.textColor = CustomColor.color1
        skin2Label.textColor = CustomColor.color1
        skin1Label.font = UIFont(name: "HelveticaNeue-Medium", size: 18*fontSizeMultiplier)
        skin2Label.font = UIFont(name: "HelveticaNeue-Medium", size: 12*fontSizeMultiplier)
        skin1Label.text = "Congrats! Bonus Game Skin"
        let skinImage1 = UIImageView(frame: CGRect(x: 42*sw, y: 445*sh, width: 50*sw, height: 50*sw))
        let skinImage2 = UIImageView(frame: CGRect(x: 42*sw, y: 528*sh, width: 50*sw, height: 50*sw))
        
        //add dots at bottom
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 606*sh, width: 375*sw, height: 45*sw))
        scrollView.contentSize = CGSize(width: 11*45*sw, height: scrollView.bounds.height)
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        let schemeArray: [ColorScheme] = [
        .lightBlue,
        .white,
        .teal,
        .darkPurple,
        .lightPurple,
        .pink,
        .red,
        .orange,
        .yellow,
        .lime,
        .green
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
