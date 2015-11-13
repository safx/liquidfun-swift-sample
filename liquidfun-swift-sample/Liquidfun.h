//
//  Liquidfun.h
//  liquidfun-swift-sample
//
//  Created by Safx Developer on 2015/04/05.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>




@interface LiquidfunWorld : NSObject
-(instancetype)initWithWidth:(float)width;
-(SKNode*)addBoxWithLocation:(CGPoint)location width:(CGFloat)width height:(CGFloat)height;
-(SKNode*)addBallWithLocation:(CGPoint)location radius:(CGFloat)radius;
-(NSArray<SKNode*>*)addWater:(CGPoint)location;
-(void)update:(float)timeStep;
@end

