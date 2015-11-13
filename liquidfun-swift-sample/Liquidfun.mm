//
//  Liquidfun.m
//  liquidfun-swift-sample
//
//  Created by Safx Developer on 2015/04/05.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

#include <Box2D/Box2d.h>
#import "Liquidfun.h"

const float DISPLAY_SCALE = 32;


@interface LiquidfunWorld () {
    b2World* _world;
    b2ParticleSystem* _particleSystem;
}
@end


@implementation LiquidfunWorld

-(instancetype)initWithWidth:(float)width {
    if (self = [super init]) {
        // Creating a World
        b2Vec2 gravity(0.0f, -10.0f);
        _world = new b2World(gravity);

        const b2ParticleSystemDef particleSystemDef;
        _particleSystem = _world->CreateParticleSystem(&particleSystemDef);
        _particleSystem->SetRadius(1.0 / 8);

        // Creating a ground box
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(width / DISPLAY_SCALE / 2, -10.0f);

        b2Body* groundBody = _world->CreateBody(&groundBodyDef);

        b2PolygonShape groundBox;
        groundBox.SetAsBox(width / DISPLAY_SCALE / 2, 10.0f);

        groundBody->CreateFixture(&groundBox, 0.0f);
    }
    return self;
}

-(void)dealloc {
    delete _world;
}

-(void)update:(float)timeStep {
    const int32 velocityIterations = 6;
    const int32 positionIterations = 2;
    _world->Step(timeStep, velocityIterations, positionIterations);

    for (b2Body* body = _world->GetBodyList(); body != nullptr; body = body->GetNext()) {
        const b2Vec2 position = body->GetPosition();
        const float32 angle = body->GetAngle();

        SKNode* node = (__bridge SKNode*) body->GetUserData();
        node.position = CGPointMake(position.x * DISPLAY_SCALE, position.y * DISPLAY_SCALE);
        node.zRotation = angle;
    }

    b2Vec2* v = _particleSystem->GetPositionBuffer();
    void** userdata = _particleSystem->GetUserDataBuffer();
    for (uint32 i = 0; i < _particleSystem->GetParticleCount(); ++i, ++v, ++userdata) {
        const bool is_remove = v->y < 0;
        SKNode* node = (__bridge SKNode*) *userdata;
        if (is_remove) {
            _particleSystem->SetParticleFlags(i, b2_zombieParticle);
            [node removeFromParent];
        } else {
            node.position = CGPointMake(v->x * DISPLAY_SCALE, v->y * DISPLAY_SCALE);
        }
    }
}

void createFixtureWithValues(b2Body* body, const b2Shape* shape, float density, float friction, float restitution) {
    b2FixtureDef def;
    def.shape = shape;
    def.density = density;
    def.friction = friction;
    def.restitution = restitution;
    body->CreateFixture(&def);
}

b2Body* createDynamicBody(b2World* world, const CGPoint& pos) {
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(pos.x / DISPLAY_SCALE, pos.y / DISPLAY_SCALE);
    return world->CreateBody(&bodyDef);
}

-(SKNode*)addBoxWithLocation:(CGPoint)location width:(CGFloat)width height:(CGFloat)height {
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithColor:UIColor.whiteColor size:CGSizeMake(width * DISPLAY_SCALE * 2, height * DISPLAY_SCALE * 2)];
    node.position = location;

    b2Body* body = createDynamicBody(_world, location);
    b2PolygonShape boxShape;
    boxShape.SetAsBox(width, height);
    createFixtureWithValues(body, &boxShape, 0.3f, 0.3f, 0.1f);
    body->SetUserData((__bridge void*) node);

    return node;
}

-(SKNode*)addBallWithLocation:(CGPoint)location radius:(CGFloat)radius {
    const float r = radius * DISPLAY_SCALE;

    SKShapeNode* node = SKShapeNode.alloc.init;
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(-r, -r, r*2, r*2)];
    node.path = ovalPath.CGPath;
    node.fillColor = UIColor.whiteColor;
    node.lineWidth = 0;
    node.position = location;

    b2Body* body = createDynamicBody(_world, location);
    b2CircleShape ballShape;
    ballShape.m_radius = radius;
    createFixtureWithValues(body, &ballShape, 1.0f, 0.8f, 0.8f);
    body->SetUserData((__bridge void*) node);

    return node;
}

-(NSArray<SKNode*>*)addWater:(CGPoint)location {
    NSMutableArray* array = [NSMutableArray array];

    b2CircleShape ballShape;
    ballShape.m_radius = 32 / DISPLAY_SCALE / 2;

    b2ParticleGroupDef groupDef;
    groupDef.shape = &ballShape;
    groupDef.flags = b2_tensileParticle;
    groupDef.position.Set(location.x / DISPLAY_SCALE, location.y / DISPLAY_SCALE);
    b2ParticleGroup* group = _particleSystem->CreateParticleGroup(groupDef);

    int32 offset = group->GetBufferIndex();
    void** userdata = _particleSystem->GetUserDataBuffer() + offset;
    for (size_t i = 0; i < group->GetParticleCount(); ++i) {
        SKEmitterNode* node = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSBundle.mainBundle pathForResource:@"water" ofType:@"sks"]];
        node.position = location;
        [array addObject:node];
        *userdata = (__bridge void*) node;
        ++userdata;
    }

    return array;
}

@end


