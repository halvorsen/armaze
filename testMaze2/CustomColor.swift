//
//  Color.swift
//  plinker
//
//  Created by Aaron Halvorsen on 7/3/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

public struct CustomColor {
    
    
    public static var purple: UIColor = UIColor(red: 149/255, green: 100/255, blue: 255/255, alpha: 1.0)
    
    
    public static let colorDictionary: [ColorScheme:UIColor] = [
        
        .tier1:
            
             UIColor(red: 56/255, green: 160/255, blue: 254/255, alpha: 1.0),
        
        .tier2:
            
             UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0),
        
        .tier3:
          
             UIColor(red: 52/255, green: 244/255, blue: 252/255, alpha: 1.0),
     
        .tier4:
     
             UIColor(red: 156/255, green: 52/255, blue: 252/255, alpha: 1.0),

        .tier5:
    
             UIColor(red: 213/255, green: 55/255, blue: 250/255, alpha: 1.0),
    
        .tier6:
         
             UIColor(red: 249/255, green: 52/255, blue: 104/255, alpha: 1.0),
    
        .tier7:
      
             UIColor(red: 252/255, green: 60/255, blue: 60/255, alpha: 1.0),
        
        .tier8:
     
             UIColor(red: 250/255, green: 192/255, blue: 65/255, alpha: 1.0),
      
        .tier9:

             UIColor(red: 252/255, green: 236/255, blue: 52/255, alpha: 1.0),
    
        .tier10:
         
             UIColor(red: 191/255, green: 251/255, blue: 63/255, alpha: 1.0),
    
        .tier11:
            
             UIColor(red: 74/255, green: 253/255, blue: 57/255, alpha: 1.0),
        
        
    ]

       
}

public enum ColorScheme: Int {
    case tier1 = 1
    case tier2 = 2
    case tier3 = 3
    case tier4 = 4
    case tier5 = 5
    case tier6 = 6
    case tier7 = 7
    case tier8 = 8
    case tier9 = 9
    case tier10 = 10
    case tier11 = 11
}



