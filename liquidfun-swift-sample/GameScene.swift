//
//  GameScene.swift
//  liquidfun-swift-sample
//
//  Created by Safx Developer on 2015/04/05.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    var world: LiquidfunWorld!

    override func didMoveToView(view: SKView) {
        world = LiquidfunWorld(width: Float(self.frame.size.width))
    }

    var count = 0
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            switch (count % 3) {
            case 0:
                addChild(world.addBoxWithLocation(location, width: 0.5, height: 0.5))
                break
            case 1:
                addChild(world.addBallWithLocation(location, radius: 0.5))
                break
            case 2: fallthrough
            default:
                for i in world.addWater(location) as [SKNode] {
                    addChild(i)
                }
                break
            }
        }
        ++count
    }

    var previousTime: CFTimeInterval = 0
    override func update(currentTime: CFTimeInterval) {
        let duration = currentTime - previousTime
        previousTime = currentTime

        let timeStep = CFloat(duration)
        world.update(timeStep)
    }
}
