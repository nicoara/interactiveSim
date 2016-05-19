//
//  ViewController.swift
//  ScenekitDemo
//
//  Created by nicoara on 5/4/16.
//  Copyright © 2016 nicoara. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {
    
    

    @IBOutlet weak var objectView: SCNView!
    @IBOutlet weak var moveButton: UIButton!
    var tappedObject: AnyObject?
    var tappedObjectNode : SCNNode = SCNNode()
    var moveButtonActivated = false
    
    var globalSCNNode : SCNNode = SCNNode()
    var globalPanRecognizer = UIPanGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let scnView = self.view as! SCNView
        let scnView = objectView
        //scnView.scene = PrimitivesScene()
        
        scnView.backgroundColor = UIColor.whiteColor()
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        
        
        //adding objects
        scnView.scene = SCNScene()
        
        let sphereGeometry = SCNSphere(radius: 1.0)
        sphereGeometry.firstMaterial?.diffuse.contents = UIColor.redColor()
        let sphereNode = SCNNode(geometry: sphereGeometry)
        scnView.scene!.rootNode.addChildNode(sphereNode)
        
        let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.blackColor()
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = SCNVector3(x: 0.1, y: 0.1, z: 3.0)
        scnView.scene!.rootNode.addChildNode(boxNode)
        
        let cone = SCNCone(topRadius: 0.2, bottomRadius: 0.1, height: 2)
        cone.firstMaterial?.diffuse.contents = UIColor.greenColor()
        let coneNode = SCNNode(geometry: cone)
        coneNode.position = SCNVector3(x: 0.0, y: 0.0, z: 2.0)
        scnView.scene!.rootNode.addChildNode(coneNode)
        
        globalSCNNode = coneNode
        scnView.scene!.rootNode.addChildNode(globalSCNNode)
        
        
        //touches
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(_:)))
        scnView.addGestureRecognizer(gestureRecognizer)
        
        moveButton.addTarget(self, action: #selector(ViewController.moveObject), forControlEvents: .TouchUpInside)
    }
    
    
    // Gestures
    var movingNow : Bool = false
    func CGPointToSCNVector3(view: SCNView, depth: Float, point: CGPoint) -> SCNVector3 {
        let projectedOrigin = view.projectPoint(SCNVector3Make(0, 0, depth))
        let locationWithz   = SCNVector3Make(Float(point.x), Float(point.y), projectedOrigin.z)
        return view.unprojectPoint(locationWithz)
    }
    func dragObject(sender: UIPanGestureRecognizer){
        if(movingNow){
            let translation = sender.translationInView(sender.view!)
            var result : SCNVector3 = CGPointToSCNVector3(objectView, depth: tappedObjectNode.position.z, point: translation)
            tappedObjectNode.position = result
        }
        else{
            let hitResults = objectView.hitTest(sender.locationInView(objectView), options: nil)
            if hitResults.count > 0 {
                movingNow = true
            }
        }
        if(sender.state == UIGestureRecognizerState.Ended) {
        }
    }
    
    func moveObject() {
        moveButtonActivated = !moveButtonActivated
        if (moveButtonActivated) {
            moveButton.backgroundColor = UIColor.redColor()
        } else{
            moveButton.backgroundColor = UIColor.clearColor()
        }
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        if(moveButtonActivated) {
            // retrieve the SCNView
            //let scnView = self.view as! SCNView
            let scnView = objectView
            
            // check what nodes are tapped
            let p = gestureRecognize.locationInView(scnView)
            let hitResults = scnView.hitTest(p, options: nil)
            
            
            if(unhighlightCurrentObject() == false){
                // check that we clicked on at least one object
                if hitResults.count > 0 {
                    // retrieved the first clicked object
                    let result: AnyObject! = hitResults[0]
                    tappedObject = result
                    tappedObjectNode = result.node
                    
                    // get its material
                    let material = result.node!.geometry!.firstMaterial!
                    
                    // highlight it
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    if(moveButtonActivated){
                        globalPanRecognizer = UIPanGestureRecognizer(target: self, action:#selector(ViewController.dragObject(_:)))
                        
                    }
                    objectView.addGestureRecognizer(globalPanRecognizer)
                    
                    
                    /*
                     // on completion - unhighlight
                     SCNTransaction.setCompletionBlock {
                     SCNTransaction.begin()
                     SCNTransaction.setAnimationDuration(0.5)
                     
                     material.emission.contents = UIColor.blackColor()
                     
                     SCNTransaction.commit()
                     }*/
                    
                    material.emission.contents = UIColor.redColor()
                    
                    SCNTransaction.commit()
                }
            }
        }
    }
    
    func unhighlightCurrentObject() ->Bool {
        if let tappedObj = tappedObject{
            
            // get its material
            let material = tappedObj.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                if(self.moveButtonActivated){
                    
                }
                
                self.objectView.removeGestureRecognizer(self.globalPanRecognizer)
                self.tappedObject = nil
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
            
            return true
        }
        else{
            return false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

