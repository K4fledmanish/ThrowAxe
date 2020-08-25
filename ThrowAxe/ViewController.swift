//
//  ViewController.swift
//  ThrowAxe
//
//  Created by Hoang Hiep Nguyen on 12/8/18.
//  Copyright © 2018 Group 2. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // add an axe button
    @IBAction func axeButton(_ sender: Any) {
        fireAxe(type: "axe")
    }
    
    @IBOutlet weak var timerBox: UILabel!
    
    @IBOutlet weak var scoreBox: UILabel!
    
    
    // decalre score veriables
    var currentScore = 0
    var highestScore = 0
    
    // algorithm of firing the axe towards target
    func calculateVector() -> (SCNVector3, SCNVector3) {
        if let sceneFrame = self.sceneView.session.currentFrame {
            let math = SCNMatrix4(sceneFrame.camera.transform)
            let direction = SCNVector3(-1 * math.m31, -1 * math.m32, -1 * math.m33)
            let position = SCNVector3(math.m41, math.m42, math.m43)
            return (direction, position)
        }

        // return the direction and position of the shoots
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view's delegate
        sceneView.delegate = self
        
        // physical contact's delegate
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // load objects to shoot at
        spreadTargetObjects()
        
        // load the timer function
        playTimer()
    }
    
    // fire the missile
    func fireAxe(type : String){
        var item = SCNNode()
        item = createAxe(type: type)
        let (targetDirection, targetPosition) = self.calculateVector()
        item.position = targetPosition
        var itemDirection = SCNVector3()
        switch type {
        case "axe":
            // 3 is the speed of objects
            itemDirection  = SCNVector3(targetDirection.x*7,targetDirection.y*7,targetDirection.z*7)
            // spinning the object - visual purpose
            item.physicsBody?.applyForce(SCNVector3(targetDirection.x,targetDirection.y,targetDirection.z), at: SCNVector3(0,0,0.1), asImpulse: true)
        default:
            itemDirection = targetDirection
        }
        // actual object fire function
        item.physicsBody?.applyForce(itemDirection , asImpulse: true)
        sceneView.scene.rootNode.addChildNode(item)
    }

    // create axe missile and fire the axe
    func createAxe(type : String)->SCNNode{
        var item = SCNNode()

        //using case statement to allow variations of scale and rotations
        switch type {
        // if user press axe button
        case "axe":
            // retrieve the .dea model
            let scene = SCNScene(named: "art.scnassets/axe.dae")

            // put the 3d model into the view
            item = (scene?.rootNode.childNode(withName: "axe", recursively: true)!)!

            // size of the model
            item.scale = SCNVector3(0.05,0.05,0.05)
            item.name = "axe"

//            runSound(soundFile: "rooster", fileType: "mp3")
            
        default:
            item = SCNNode()
        }
    
        // add physical effects to the axe models
        item.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        item.physicsBody?.isAffectedByGravity = false
        
        // get the axe models bitmasks
        item.physicsBody?.categoryBitMask = ObjectCollisionType.axeModelType.rawValue
        item.physicsBody?.collisionBitMask = ObjectCollisionType.targetModelType.rawValue
        return item
    }
    
    //Adds 100 objects to the scene, spins them, and places them at random positions around the player.
    func spreadTargetObjects(){
        // make a loop to generate targeted objects
        for counter in 1...100 {
            
            // variable for targeted objects
            var object = SCNNode()
            
            // random flying target objects
            
            // ship 3d models
            if (counter % 3 == 0) {
                let scene = SCNScene(named: "art.scnassets/ship.scn")
                object = (scene?.rootNode.childNode(withName: "ship", recursively: true)!)!
                object.scale = SCNVector3(1,1,1)
                object.name = "ship"
            }
            
            // rocket 3d models
            else if (counter % 3 == 1) {
                let scene = SCNScene(named: "art.scnassets/rocket.dae")
                object = (scene?.rootNode.childNode(withName: "Cylinder", recursively: true)!)!
                object.scale = SCNVector3(0.3,0.3,0.3)
                object.name = "rocket"
            }
                
            // box 3d models
            else{
                let scene = SCNScene(named: "art.scnassets/crate.dae")
                object = (scene?.rootNode.childNode(withName: "box", recursively: true)!)!
                object.scale = SCNVector3(0.1,0.1,0.1)
                object.name = "crate"
            }
            
            // apply phisical effects upon those objects
            object.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            object.physicsBody?.isAffectedByGravity = false
            
            //put target randomly at different position on the phone view
            object.position = SCNVector3(flyRandomly(min: -10, max: 10),flyRandomly(min: -4, max: 5),flyRandomly(min: -10, max: 10))
            
            // make the objects rotate constantly
            let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
            let forever = SCNAction.repeatForever(action)
            object.runAction(forever)
            
            
            // get the target model object bitmasks
            object.physicsBody?.categoryBitMask = ObjectCollisionType.targetModelType.rawValue
            object.physicsBody?.contactTestBitMask = ObjectCollisionType.axeModelType.rawValue
            
            // actually add the objects to scene when this function is called
            sceneView.scene.rootNode.addChildNode(object)
        }
    }
    
    // this function generate random position figures
    func flyRandomly(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    // this function is called when objects are collided - part of SCNPhysicsContactDelegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin colide: SCNPhysicsContact) {
        
        // output the info about collision when occuring
        print("Collision detected: " + colide.nodeA.name! + "and " + colide.nodeB.name! + "are colided.")
        
        // increase game score depending on which terget objects are shoot
        if colide.nodeA.physicsBody?.categoryBitMask == ObjectCollisionType.targetModelType.rawValue
            || colide.nodeB.physicsBody?.categoryBitMask == ObjectCollisionType.targetModelType.rawValue {
            
            // 1 score for ships
            if (colide.nodeA.name! == "ship" || colide.nodeB.name! == "ship") {
                currentScore += 1
            }
                
            // 2 scores for rocket
            else if (colide.nodeA.name! == "rocket" || colide.nodeB.name! == "rocket"){
                currentScore += 2
            }
                
            // 3 scores for crates
            else {
                currentScore += 3
            }
            
            // remove colided objects from the view
            DispatchQueue.main.async {
                colide.nodeA.removeFromParentNode()
                colide.nodeB.removeFromParentNode()
                
                if (self.currentScore > self.highestScore)
                {
                    self.highestScore = self.currentScore
                }
                self.scoreBox.text = String(self.highestScore)
            }

//            runSound(soundFile: "explosion", fileType: "wav")
//            let  explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
//            colide.nodeB.addParticleSystem(explosion!)
        }
    }
    
//    var soundPlayer: AVAudioPlayer?
//
//    func runSound(soundFile : String, fileType: String) {
//        guard let filePath = Bundle.main.url(forResource: soundFile, withExtension: fileType) else { return }
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
//            try AVAudioSession.sharedInstance().setActive(true)
//
//
//            soundPlayer = try AVAudioPlayer(contentsOf: filePath, fileTypeHint: AVFileType.mp3.rawValue)
//
//            guard let player = soundPlayer else { return }
//            player.play()
//        } catch let exception {
//            print(exception.localizedDescription)
//        }
//    }
    
    
//    // run background music
//    func playBackgroundMusic(){
//        let audioNode = SCNNode()
//        let audioSource = SCNAudioSource(fileNamed: "overtake.mp3")!
//        let audioPlayer = SCNAudioPlayer(source: audioSource)
//
//        audioNode.addAudioPlayer(audioPlayer)
//
//        let play = SCNAction.playAudio(audioSource, waitForCompletion: true)
//        audioNode.runAction(play)
//        sceneView.scene.rootNode.addChildNode(audioNode)
//    }
    
    
    // codes for counting time
    var timeCounter = 60
    var gameTimer = Timer()
    var gameIsRunning = false
    
    func playTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    // function handling the timer
    @objc func updateTimer() {
        // end game when running out of time
        if timeCounter == 0 {
            gameTimer.invalidate()
            endGame()
            
        // count down the game timer and show in the timerBox
        }else{
            timeCounter -= 1
            timerBox.text = "\(timeCounter)"
        }
        
    }
    
    func restartTimer(){
        gameTimer.invalidate()
        timeCounter = 90
        timerBox.text = "\(timeCounter)"
    }

    // handling game when time runs out
    func endGame(){
        // save the last score into defaultScore
        let defaultScore = UserDefaults.standard
        defaultScore.set(highestScore, forKey: "score")
        
        // return into the home view
        self.dismiss(animated: true, completion: nil)
    }

    // auto generated codes
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
    }
}

// build a struct of each 3d object type's bitmasks
struct ObjectCollisionType: OptionSet {
    let rawValue: Int
    
    // bitmasks for each type of 3d model object
    static let axeModelType  = ObjectCollisionType(rawValue: 1 << 0)
    static let targetModelType = ObjectCollisionType(rawValue: 1 << 1)
    static let otherModelType = ObjectCollisionType(rawValue: 1 << 2)
}
