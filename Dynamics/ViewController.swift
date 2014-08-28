//
//  ViewController.swift
//  Dynamics
//
//  Created by Andrew Cavanagh on 8/27/14.
//  Copyright (c) 2014 WeddingWire. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    // Play with these three properties
    let size: CGFloat = 20
    let numBoxes: Int = 75
    let gMagnitude: CGFloat = 1.0
    
    
    
    // Logic
    
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collisionBehavior: UICollisionBehavior!
    var boxes: [UIView] = []
    
    var maxX: CGFloat = UIScreen.mainScreen().bounds.size.width
    var maxY: CGFloat = UIScreen.mainScreen().bounds.size.height

    var motionManager = CMMotionManager()
    var opQueue = NSOperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateBoxes()
    }

    func boxCollidesWithBoxes(box: CGRect) -> Bool {
        for testBox: UIView in boxes {
            if (CGRectIntersectsRect(testBox.frame, box)) {
                return true
            }
        }
        return false
    }
    
    func randColor() -> UIColor {
        let red = CGFloat(CGFloat(arc4random()%100000)/100000)
        let green = CGFloat(CGFloat(arc4random()%100000)/100000)
        let blue = CGFloat(CGFloat(arc4random()%100000)/100000)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func randFrame() -> CGRect {
        var rect = CGRectZero
        do {
            let x = CGFloat(arc4random()) % (maxX - size)
            let y = CGFloat(arc4random()) % (maxY - 100 - size);
            rect = CGRect(x: x, y: y, width: size, height: size)
        } while (boxCollidesWithBoxes(rect))
        return rect
    }
    
    func generateBoxes() {
        for index in 1...self.numBoxes {
            var view = UIView(frame: randFrame())
            view.backgroundColor = randColor()
            self.view.addSubview(view)
            boxes.append(view)
        }
        setupAnimations()
    }
    
    func setupAnimations() {
        animator = UIDynamicAnimator(referenceView: self.view)
        
        gravity = UIGravityBehavior(items: boxes)
        gravity.magnitude = gMagnitude
        animator.addBehavior(gravity)
        
        collisionBehavior = UICollisionBehavior(items: boxes)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collisionBehavior)
        
        motionManager.startDeviceMotionUpdatesToQueue(opQueue, withHandler: { (motion: CMDeviceMotion!, error: NSError!) -> Void in
            if (error != nil) {
                println(error.description)
            }
            
            let g: CMAcceleration = motion.gravity
            let x = CGFloat(g.x)
            let y = CGFloat(g.y)
            
            var vector = CGVectorMake(x, -y)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.gravity.gravityDirection = vector
            })
        })
    }
}

