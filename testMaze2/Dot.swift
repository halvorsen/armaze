//
//  dot.swift
//  plinker
//
//  Created by Aaron Halvorsen on 7/14/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

protocol DotTap: class {
    func tap(colorScheme: ColorScheme, myIndex: Int)
}

class Dot: UIView {
    var myIndex = Int()
    var dotColor = UIColor()
    var _colorScheme:ColorScheme?
    var tap = UITapGestureRecognizer()
    var tapDelegate:DotTap?
    var shapeLayer = CAShapeLayer()
    init(size: CGSize = CGSize(width: CGFloat(Int(45*UIScreen.main.bounds.width/375)), height: CGFloat(Int(45*UIScreen.main.bounds.width/375))), color: UIColor, origin: CGPoint, colorScheme: ColorScheme) {
        super.init(frame: CGRect(origin: origin, size: size))
        dotColor = color
        tap = UITapGestureRecognizer(target: self, action: #selector(Dot.tapFunc(_:)))
        _colorScheme = colorScheme
        self.backgroundColor = .clear
        self.addGestureRecognizer(tap)
        
        print("dotframe: \(self.frame), scheme \(_colorScheme!)")
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: CGFloat(Int(22.5*UIScreen.main.bounds.width/375)), y: CGFloat(Int(22.5*UIScreen.main.bounds.width/375)) ), radius: CGFloat(Int(15*UIScreen.main.bounds.width/375)), startAngle: 0, endAngle:2 * .pi, clockwise: true)
        
        
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = dotColor.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
      //  shapeLayer.borderColor = UIColor.black.cgColor
        self.layer.addSublayer(shapeLayer)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapFunc(_ gesture: UITapGestureRecognizer) {
        print("tapped: \(_colorScheme!)")
        tapDelegate?.tap(colorScheme: _colorScheme!, myIndex: self.myIndex)
        
    }
   
//    override func draw(_ rect: CGRect) {
//        let aPath = UIBezierPath()
//        aPath.addArc(withCenter: self.center, radius: 15*UIScreen.main.bounds.width/375, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        aPath.close()
//
//        dotColor.set()
//       
//        aPath.fill()
//    }
 

}
