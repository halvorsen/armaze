//
//  PurchaseButton.swift
//  plinker
//
//  Created by Aaron Halvorsen on 6/26/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit




class SubscribeToPremiumButton: UIButton, BrothersUIAutoLayout {
 
    init() {super.init(frame: .zero)}
    init(color: UIColor, origin: CGPoint) {
        super.init(frame: .zero)
        
        self.setTitle("UNLOCK WEAPONS", for: .normal)
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 19*fontSizeMultiplier)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = color
        self.frame.size = CGSize(width: 243*sw, height: 42*sh)
        if UIScreen.main.bounds.height == 812 {
            self.frame.size = CGSize(width: 243*sw, height: 42*sw)
        }
        self.frame.origin = origin
        self.addTextSpacing(spacing: 1.46*fontSizeMultiplier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
}

class PlayButton: UIButton, BrothersUIAutoLayout {
  
    init() {super.init(frame: .zero)}
    init(color: UIColor, origin: CGPoint) {
        super.init(frame: .zero)
        self.setTitle("PLAY", for: .normal)
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 19*fontSizeMultiplier)
        self.setTitleColor(.black, for: .normal)
        self.backgroundColor = color
        self.frame.size = CGSize(width: 72*sw, height: 42*sh)
        if UIScreen.main.bounds.height == 812 {
            self.frame.size = CGSize(width: 72*sw, height: 42*sw)
        }
        self.frame.origin = origin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ReplayButton: UIButton, BrothersUIAutoLayout {
    
    init() {super.init(frame: .zero)}
    init(color: UIColor, origin: CGPoint) {
        super.init(frame: .zero)
        self.setTitle("DROP MAZE", for: .normal)
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 19*fontSizeMultiplier)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = color
        self.frame.size = CGSize(width: 173*sw, height: 42*sh)
        if UIScreen.main.bounds.height == 812 {
            self.frame.size = CGSize(width: 173*sw, height: 42*sw)
        }
        self.frame.origin = origin
        self.addTextSpacing(spacing: 1.46*fontSizeMultiplier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class GameCenterButton: UIButton, BrothersUIAutoLayout {
    
    init() {super.init(frame: .zero)}
    init(color: UIColor, origin: CGPoint) {
        super.init(frame: .zero)
        self.setTitle("INSTRUCTIONS", for: .normal)
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 19*fontSizeMultiplier)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = color
        self.frame.size = CGSize(width: 203*sw, height: 42*sh)
        if UIScreen.main.bounds.height == 812 {
            self.frame.size = CGSize(width: 203*sw, height: 42*sw)
        }
        self.frame.origin = origin
        self.addTextSpacing(spacing: 1.46*fontSizeMultiplier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MenuButton: UIButton, BrothersUIAutoLayout {
    
    init() {super.init(frame: .zero)}
    init(color: UIColor, origin: CGPoint) {
        super.init(frame: .zero)
        self.setTitle("MENU", for: .normal)
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 19*fontSizeMultiplier)
        self.setTitleColor(.black, for: .normal)
        self.backgroundColor = color
        self.frame.size = CGSize(width: 77*sw, height: 42*sh)
        if UIScreen.main.bounds.height == 812 {
            self.frame.size = CGSize(width: 77*sw, height: 42*sw)
        }
        self.frame.origin = origin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class OneMoreLife: UIButton, BrothersUIAutoLayout {
    
    init() {super.init(frame: .zero)}
    init(color: UIColor, origin: CGPoint) {
        super.init(frame: .zero)
        self.setTitle("UNLOCK WEAPONS", for: .normal)
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18*fontSizeMultiplier)
        self.setTitleColor(.white, for: .normal)
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 2
        self.backgroundColor = .clear
        self.frame.size = CGSize(width: 243*sw, height: 42*sh)
        if UIScreen.main.bounds.height == 812 {
            self.frame.size = CGSize(width: 243*sw, height: 42*sw)
        }
        self.frame.origin = origin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

