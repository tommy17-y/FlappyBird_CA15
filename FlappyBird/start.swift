//
//  start.swift
//  FlappyBird
//
//  Created by Yuki Tomiyoshi on 2014/07/26.
//  Copyright (c) 2014年 Fullstack.io. All rights reserved.
//

import Foundation
import SpriteKit

class start: SKScene, SKPhysicsContactDelegate {
    var titleLabelNode : SKLabelNode!
    var startButtonNode : SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        titleLabelNode = SKLabelNode(fontNamed:"Chalkduster")
        titleLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), self.frame.size.height / 8 * 5 )
        titleLabelNode.zPosition = 100
        titleLabelNode.text = "Swifty Bird"
        titleLabelNode.fontSize = 60.0
        titleLabelNode.verticalAlignmentMode = .Center
        self.addChild(titleLabelNode)
        
        
        let birdTexture1 = SKTexture(imageNamed: "bird-01")
        
        startButtonNode = SKSpriteNode(texture : birdTexture1)
        startButtonNode.anchorPoint = CGPointMake(0.0, 0.0)
        startButtonNode.size = CGSizeMake(self.frame.size.width / 8,
            self.frame.size.width / 15)
        startButtonNode.position = CGPointMake((self.frame.size.width - startButtonNode.frame.size.width) / 2,
            (self.frame.size.height - startButtonNode.frame.size.height) / 5)
        startButtonNode.name = "start"
        self.addChild(startButtonNode)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if let name = node.name {
                if name == "start" {
                    //遷移
                    if let scene = GameScene.unarchiveFromFileForGameScene("GameScene") as? GameScene {
                        let skView = self.view as SKView
                        skView.showsFPS = true
                        skView.showsNodeCount = true
                        
                        /* Sprite Kit applies additional optimizations to improve rendering performance */
                        skView.ignoresSiblingOrder = true
                        
                        /* Set the scale mode to scale to fit the window */
                        scene.scaleMode = .AspectFill
                        
                        self.view.presentScene(scene)
                    }
                }
            }
        }
    }
    
}
