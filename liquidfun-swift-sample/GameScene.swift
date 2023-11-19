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

    override func didMove(to view: SKView) {
        world = LiquidfunWorld(width: Float(self.frame.size.width))
    }

    var count = 0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            switch (count % 3) {
            case 0:
                addChild(world.addBox(withLocation: location, width: 0.5, height: 0.5))
                break
            case 1:
                addChild(world.addBall(withLocation: location, radius: 0.5))
                break
            case 2: fallthrough
            default:
                for i in world.addWater(location) as [SKNode] {
                    addChild(i)
                }
                break
            }
        }
        count += 1
    }

    var previousTime: CFTimeInterval = 0
    override func update(_ currentTime: CFTimeInterval) {
        let duration = currentTime - previousTime
        previousTime = currentTime

        let timeStep = CFloat(duration)
        world.update(timeStep)
    }
}
