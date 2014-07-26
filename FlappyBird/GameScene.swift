//
//  GameScene.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    var verticalPipeGap = 300.0
    
    var bird:SKSpriteNode!
    var skyColor:SKColor!
    var pipeTextureUp:SKTexture!
    var pipeTextureDown:SKTexture!
    var movePipesAndRemove:SKAction!
    var moving:SKNode!
    var pipes:SKNode!
    var items:SKNode!
    var moveItemsAndRemove:SKAction!
    var canRestart = Bool()
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    var sounds = PlaySounds()
    
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let itemCategory: UInt32 = 1 << 4
    
    override func didMoveToView(view: SKView) {

        canRestart = false
        
        // setup physics
        self.physicsWorld.gravity = CGVectorMake( 0.0, 5.0 )
        self.physicsWorld.contactDelegate = self
        
        // setup background color
        skyColor = SKColor(red: 255.0/255.0, green: 120.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        moving = SKNode()
        
        //5倍速
        moving.speed = 5
        
        self.addChild(moving)
        pipes = SKNode()
        moving.addChild(pipes)
        items = SKNode()
        moving.addChild(items)
        
        
        // skyline
        let skyTexture = SKTexture(imageNamed: "mount.png")
        skyTexture.filteringMode = .Nearest
        var mountNode : SKSpriteNode! = SKSpriteNode(texture : skyTexture)
        mountNode.anchorPoint = CGPointMake(0.0, 0.0)
        mountNode.size = CGSizeMake(self.frame.size.width ,
            self.frame.size.height / 2)
        mountNode.position = CGPointMake(100, 0)
        
        self.addChild(mountNode)

        
        // ground
        let groundTexture = SKTexture(imageNamed: "land2.png")
        groundTexture.filteringMode = .Nearest // shorter form for SKTextureFilteringMode.Nearest
        
        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.02 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( groundTexture.size().width * 2.0 ); ++i {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.5)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0)
            sprite.runAction(moveGroundSpritesForever)
            moving.addChild(sprite)
        }

        
        // Upper
        let UpperTexture = SKTexture(imageNamed: "land_inv")
        UpperTexture.filteringMode = .Nearest // shorter form for SKTextureFilteringMode.Nearest
        
        let moveUpperSprite = SKAction.moveByX(-UpperTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.02 * UpperTexture.size().width * 2.0))
        let resetUpperSprite = SKAction.moveByX(UpperTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveUpperSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveUpperSprite,resetUpperSprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( groundTexture.size().width * 2.0 ); ++i {
            let sprite = SKSpriteNode(texture: UpperTexture)
            sprite.setScale(2.0)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0 + 770)
            sprite.runAction(moveUpperSpritesForever)
            moving.addChild(sprite)
        }
        
        
        // create the pipes textures
        pipeTextureUp = SKTexture(imageNamed: "pipeUP.png")
        pipeTextureUp.filteringMode = .Nearest
        pipeTextureDown = SKTexture(imageNamed: "pipeDOWN.png")
        pipeTextureDown.filteringMode = .Nearest
        
        // create the pipes movement actions
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeTextureUp.size().width)
        let movePipes = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        // spawn the pipes
        let spawn = SKAction.runBlock({() in self.spawnPipes()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        
        // create the items movement actions
        let moveItems = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove))
        let removeItems = SKAction.removeFromParent()
        moveItemsAndRemove = SKAction.sequence([moveItems, removeItems])
        
        // spawn the items
        let spawnItem = SKAction.runBlock({() in self.spawnItems()})
        let delayItem = SKAction.waitForDuration(NSTimeInterval(4.0))
        let spawnThenDelayItem = SKAction.sequence([spawnItem, delayItem])
        let spawnThenDelayForeverItem = SKAction.repeatActionForever(spawnThenDelayItem)
        self.runAction(spawnThenDelayForeverItem)
        
        // setup our bird
        let birdTexture1 = SKTexture(imageNamed: "swift_bird.png")
        birdTexture1.filteringMode = .Nearest
        let birdTexture2 = SKTexture(imageNamed: "swift_bird.png")
        birdTexture2.filteringMode = .Nearest
        
        let anim = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(2.0)
        bird.position = CGPoint(x: self.frame.size.width * 0.35, y:self.frame.size.height * 0.35)
        bird.runAction(flap)
        
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody.dynamic = true
        bird.physicsBody.allowsRotation = false
        
        bird.physicsBody.categoryBitMask = birdCategory
        bird.physicsBody.collisionBitMask = worldCategory | pipeCategory
        bird.physicsBody.contactTestBitMask = worldCategory | pipeCategory
        
        self.addChild(bird)
        
        // create the ground
        var ground = SKNode()
        ground.position = CGPointMake(0, groundTexture.size().height - 100)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2.0))
        ground.physicsBody.dynamic = false
        ground.physicsBody.categoryBitMask = worldCategory
        self.addChild(ground)
        
        // create the Upper
        var Upper = SKNode()
        Upper.position = CGPointMake(0, groundTexture.size().height + 770)
        Upper.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2.0))
        Upper.physicsBody.dynamic = false
        Upper.physicsBody.categoryBitMask = worldCategory
        self.addChild(Upper)
        
        // Initialize label and create a label which holds the score
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        scoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), 3 * self.frame.size.height / 4 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
        
        sounds.playBGM("default") // sounds
        
    }
    
    func spawnPipes() {
        let pipePair = SKNode()
        pipePair.position = CGPointMake( self.frame.size.width + pipeTextureUp.size().width * 2, -100 )
        pipePair.zPosition = -10
        
        let height = UInt32( Float(self.frame.size.height) / 4 )
        let yyy = arc4random() % height + height
        
        let pipeDown = SKSpriteNode(texture: pipeTextureDown)
        pipeDown.setScale(2.0)
        let zero : CGFloat = 0.0
        let cgfloatY : CGFloat = CGFloat(Float(yyy))
        pipeDown.position = CGPointMake(zero, pipeDown.size.height + CGFloat(verticalPipeGap) - min(score, 10)*10 + cgfloatY)
        
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody.dynamic = false
        pipeDown.physicsBody.categoryBitMask = pipeCategory
        pipeDown.physicsBody.contactTestBitMask = birdCategory
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeTextureUp)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPointMake(zero, cgfloatY)
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody.dynamic = false
        pipeUp.physicsBody.categoryBitMask = pipeCategory
        pipeUp.physicsBody.contactTestBitMask = birdCategory
        pipePair.addChild(pipeUp)
        
        var contactNode = SKNode()
        contactNode.position = CGPointMake( pipeDown.size.width + bird.size.width / 2, CGRectGetMidY( self.frame ) )
        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake( pipeUp.size.width, self.frame.size.height ))
        contactNode.physicsBody.dynamic = false
        contactNode.physicsBody.categoryBitMask = scoreCategory
        contactNode.physicsBody.contactTestBitMask = birdCategory
        pipePair.addChild(contactNode)
        
        pipePair.runAction(movePipesAndRemove)
        pipes.addChild(pipePair)
        
    }
    
    func spawnItems() {
        let itemPair = SKNode()
        itemPair.position = CGPointMake( self.frame.size.width - pipeTextureUp.size().width * 2, 0 )
        itemPair.zPosition = -10
        
        let height = UInt32( Float(self.frame.size.height) / 3 )
        let yyy = arc4random() % height + height
        
        let item = SKSpriteNode(texture: SKTexture(imageNamed: "item-01.png"))
        item.setScale(0.6)
        let cgfloatY : CGFloat = CGFloat(Float(yyy))
        item.position = CGPointMake(0.0, cgfloatY)
        
        
        item.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        item.physicsBody.dynamic = false
        item.physicsBody.categoryBitMask = itemCategory
        item.physicsBody.contactTestBitMask = birdCategory
        itemPair.addChild(item)
        
        itemPair.runAction(moveItemsAndRemove)
        items.addChild(itemPair)
        
    }
    
    func resetScene (){
        sounds.reset() // sounds
        
        
        // Move bird to original position and reset velocity
        bird.position = CGPointMake(self.frame.size.width / 2.5, CGRectGetMidY(self.frame))
        bird.physicsBody.velocity = CGVectorMake( 0, 0 )
        bird.physicsBody.collisionBitMask = worldCategory | pipeCategory
        bird.speed = 1.0
        bird.zRotation = 0.0
        
        // Reset gravity
        self.physicsWorld.gravity = CGVectorMake( 0.0, 5.0 )
        
        // Remove all existing pipes
        pipes.removeAllChildren()
        
        // Remove all existing items
        items.removeAllChildren()
        
        // Reset _canRestart
        canRestart = false
        
        // Reset score
        score = 0
        scoreLabelNode.text = String(score)
        
        // Restart animation
        moving.speed = 5
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        if moving.speed > 0  {
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                
                bird.physicsBody.velocity = CGVectorMake(0, 0)
                bird.physicsBody.applyImpulse(CGVectorMake(0, -30))
                
                sounds.playSE("jump") // sounds
                
            }
        }else if canRestart {
            self.resetScene()
        }
    }
    
    // TODO: Move to utilities somewhere. There's no reason this should be a member function
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max
        } else if( value < min ) {
            return min
        } else {
            return value
        }
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        bird.zRotation = self.clamp( -1, max: 0.5, value: bird.physicsBody.velocity.dy * ( bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) )
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if moving.speed > 0 {
            if ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
                // Bird has contact with score entity
                score++
                scoreLabelNode.text = String(score)


                
                // Add a little visual feedback for the score increment
                scoreLabelNode.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration:NSTimeInterval(0.1)), SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))]))
            } else if ( contact.bodyA.categoryBitMask & itemCategory ) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
                
                if ( contact.bodyA.categoryBitMask & itemCategory ) == itemCategory {
                    var node : SKSpriteNode = contact.bodyA.node as SKSpriteNode
                    node.removeFromParent()
                    
                } else {
                    var node : SKSpriteNode = contact.bodyB.node as SKSpriteNode
                    node.removeFromParent()
                }
                
            } else {
                
                moving.speed = 0
                
                bird.physicsBody.collisionBitMask = worldCategory
                bird.runAction(  SKAction.rotateByAngle(CGFloat(M_PI) * CGFloat(bird.position.y) * 0.01, duration:1), completion:{self.bird.speed = 0 })
                
                sounds.playSE("death") // sounds
                sounds.stopBGM() // sounds
                
                // Flash background if contact is detected
                self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 )
                self.removeActionForKey("flash")
                self.runAction(SKAction.sequence([SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({
                    self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
                    }),SKAction.waitForDuration(NSTimeInterval(0.05)), SKAction.runBlock({
                        self.backgroundColor = self.skyColor
                        }), SKAction.waitForDuration(NSTimeInterval(0.05))]), count:4), SKAction.runBlock({
                            self.canRestart = true
                            })]), withKey: "flash")
                
                self.gameOver()
            }
        }
    }
    
    func gameOver () {
        
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.scoreNum = score
        
        if let scene = end.unarchiveFromFileForEnd("end") as? end {
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
