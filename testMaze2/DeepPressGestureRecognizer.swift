//
//  ForcePress.swift
//  testMaze2
//
//  Created by Jenn Halvorsen on 8/28/17.
//  Copyright © 2017 Right Brothers. All rights reserved.
//

import AudioToolbox
import UIKit.UIGestureRecognizerSubclass

//Without this import line, you'll get compiler errors when implementing your touch methods since they aren't part of the UIGestureRecognizer superclass
//import UIKit.UIGestureRecognizerSubclass
//
//public class DeepPressGestureRecognizer: UIGestureRecognizer {
//    //Because we don't know what the maximum force will always be for a UITouch, the force property here will be normalized to a value between 0.0 and 1.0.
//    public private(set) var force: CGFloat = 0.0
//    public var maximumForce: CGFloat = 4.0
//
//    convenience init() {
//        self.init(target: nil, action: nil)
//    }
//
//    //We override the initializer because UIGestureRecognizer's cancelsTouchesInView property is true by default. If you were to, say, add this recognizer to a tableView's cell, it would prevent didSelectRowAtIndexPath from getting called. Thanks for finding this bug, Jordan Hipwell!
//    public override init(target: Any?, action: Selector?) {
//        super.init(target: target, action: action)
//        cancelsTouchesInView = false
//    }
//
//    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesBegan(touches, with: event)
//        normalizeForceAndFireEvent(.began, touches: touches)
//    }
//
//    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesMoved(touches, with: event)
//        normalizeForceAndFireEvent(.changed, touches: touches)
//    }
//
//    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesEnded(touches, with: event)
//        normalizeForceAndFireEvent(.ended, touches: touches)
//    }
//
//    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesCancelled(touches, with: event)
//        normalizeForceAndFireEvent(.cancelled, touches: touches)
//    }
//
//    private func normalizeForceAndFireEvent(_ state: UIGestureRecognizerState, touches: Set<UITouch>) {
//        //Putting a guard statement here to make sure we don't fire off our target's selector event if a touch doesn't exist to begin with.
//        guard let firstTouch = touches.first else { return }
//
//        //Just in case the developer set a maximumForce that is higher than the touch's maximumPossibleForce, I'm setting the maximumForce to the lower of the two values.
//        maximumForce = min(firstTouch.maximumPossibleForce, maximumForce)
//
//        //Now that I have a proper maximumForce, I'm going to use that and normalize it so the developer can use a value between 0.0 and 1.0.
//        force = firstTouch.force / maximumForce
//
//        //Our properties are now ready for inspection by the developer. By setting the UIGestureRecognizer's state property, the system will automatically send the target the selector message that this recognizer was initialized with.
//        self.state = state
//    }
//
//    //This function is called automatically by UIGestureRecognizer when our state is set to .Ended. We want to use this function to reset our internal state.
//    public override func reset() {
//        super.reset()
//        force = 0.0
//    }


class DeepPressGestureRecognizer: UIGestureRecognizer
{
    var vibrateOnDeepPress = true
    var threshold:CGFloat = 0.75
    var hardTriggerMinTime:TimeInterval = 0.5
    
    private var deepPressed: Bool = false
    private var deepPressedAt: TimeInterval = 0
    private var k_PeakSoundID:UInt32 = 1519
    private var hardAction:Selector?
    private var target: AnyObject?
    
    init() {
        super.init(target: nil, action: nil)
    }
    
    init(target: AnyObject?, action: Selector, hardAction:Selector?=nil, threshold: CGFloat = 0.75)
    {
        self.target = target
        self.hardAction = hardAction
        self.threshold = threshold
        
        super.init(target: target, action: action)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent)
    {
        if let touch = touches.first
        {
            handleTouch(touch: touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent)
    {
        if let touch = touches.first
        {
            handleTouch(touch: touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesEnded(touches, with: event)
        
        state = deepPressed ? UIGestureRecognizerState.ended : UIGestureRecognizerState.failed
        
        deepPressed = false
    }
    
    private func handleTouch(touch: UITouch)
    {
        guard let _ = view, touch.force != 0 && touch.maximumPossibleForce != 0 else
        {
            return
        }
        
        let forcePercentage = (touch.force / touch.maximumPossibleForce)
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        if !deepPressed && forcePercentage >= threshold
        {
            state = UIGestureRecognizerState.began
            
            if vibrateOnDeepPress
            {
                AudioServicesPlaySystemSound(k_PeakSoundID)
            }
            
            deepPressedAt = NSDate.timeIntervalSinceReferenceDate
            deepPressed = true
        }
        else if deepPressed && forcePercentage <= 0
        {
            endGesture()
        }
        else if deepPressed && currentTime - deepPressedAt > hardTriggerMinTime && forcePercentage == 1.0
        {
            endGesture()
            
            if vibrateOnDeepPress
            {
                AudioServicesPlaySystemSound(k_PeakSoundID)
            }
            
            //fire hard press
            if let hardAction = self.hardAction, let target = self.target {
                target.perform(hardAction)
                // target.perform(hardAction, withObject: self)
            }
        }
    }
    
    func endGesture() {
        state = UIGestureRecognizerState.ended
        deepPressed = false
    }
}

// MARK: DeepPressable protocol extension
protocol DeepPressable
{
    var gestureRecognizers: [UIGestureRecognizer]? {get set}
    
    func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer)
    func removeGestureRecognizer(gestureRecognizer: UIGestureRecognizer)
    
    func setDeepPressAction(target: AnyObject, action: Selector)
    func removeDeepPressAction()
}

extension DeepPressable
{
    func setDeepPressAction(target: AnyObject, action: Selector)
    {
        let deepPressGestureRecognizer = DeepPressGestureRecognizer(target: target, action: action, threshold: 0.75)
        
        self.addGestureRecognizer(gestureRecognizer: deepPressGestureRecognizer)
    }
    
    func removeDeepPressAction()
    {
        guard let gestureRecognizers = gestureRecognizers else
        {
            return
        }
        
        for recogniser in gestureRecognizers where recogniser is DeepPressGestureRecognizer
        {
            removeGestureRecognizer(gestureRecognizer: recogniser)
        }
    }
}
