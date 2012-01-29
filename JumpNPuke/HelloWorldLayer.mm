//
//  HelloWorldLayer.mm
//  Test22
//
//  Created by Vincent on 28/01/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "JNPBasicLayer.h"

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

id elephantNormalTexture,elephantPukeTexture, elephantJumpTexture;

@interface HelloWorldLayer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
@end

static JNPControlLayer * controlLayer;

// ta mere elle mange des pruneaux

@implementation HelloWorldLayer

@synthesize playerBody;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer * baseLayer = [HelloWorldLayer node];
	controlLayer = [JNPControlLayer node];
	[controlLayer assignGameLayer:baseLayer];
	
    CCLayer *bgLayer = [CCLayer node];
    CGSize s = [CCDirector sharedDirector].winSize;
    
    // init du background
    CCSprite *bgpic = [CCSprite spriteWithFile:@"fondpapier.png"];
    bgpic.position = ccp(bgpic.position.x + s.width/2.0, bgpic.position.y+s.height/2.0);
    bgpic.opacity = 160;
    [bgLayer addChild:bgpic];
    [scene addChild:bgLayer];
    
    JNPAudioManager *audioManager = [[[JNPAudioManager alloc] init] autorelease];
    [audioManager playMusic:1];
    
    [scene addChild:audioManager];
    [baseLayer setAudioManager:audioManager];
    
	// add layer as a child to scene
	[scene addChild: baseLayer];
	[scene addChild: controlLayer z:5 tag:2];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        
        
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		hasWon = NO;
       
		// init de la Map avant box2d
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"map.tmx"];
        self.background = [_tileMap layerNamed:@"background"];
        [self addChild:_tileMap z:0];
        
        // obtention des positions potentielles de super bonus ta mère
        CCTMXObjectGroup *bonusGroup = [_tileMap objectGroupNamed:@"bonus"];
        NSMutableArray *tableauObjets = [bonusGroup objects];
        int nomber = [tableauObjets count];
        
        
        // initiailisation des bonus collectables
        lesBonusDeTaMere = [NSMutableArray array];

        
        JNPScore *s = [JNPScore jnpscore];
        NSMutableArray *tmpVomis = s.vomis;
        
        // s'il y a trop de vomi, on en supprime jusqu'à ce qu'il ne reste plus que 23 vomis
        if ([tmpVomis count]>20) {
            while ([tmpVomis count]>20) {
                [tmpVomis removeObjectAtIndex:(arc4random()%[tmpVomis count])];
            }
        }
        
        int inheritedVomiCounter = 0;
        for (CCSprite *sprout in tmpVomis) {
            inheritedVomiCounter++;
            [self addChild:sprout];
            [lesBonusDeTaMere addObject:sprout];
        }
        
        // S'il y a moins de 12 vomis, on ajoute des bonus aléatoirement sur la map parmis de positions prévues;
        int maxBonus = 12;
        maxBonus -= inheritedVomiCounter;
        
        
        // grande cagnotte tirage au sort parmis les positions possibles de bonus, pour obtenir un tableau de quelques points différents sur lesquels placer des cadeaux bonux
        NSMutableArray *electedBonusPositionsInMap = [NSMutableArray arrayWithCapacity:12];
        if (maxBonus>0) {
            for (int ii=0; ii<maxBonus; ii++) {
                int kk = arc4random() % nomber;
                [electedBonusPositionsInMap insertObject:[tableauObjets objectAtIndex:kk] atIndex:ii];
                [tableauObjets removeObjectAtIndex:kk];
                nomber--;
            }
            
            
            // après le tirage au sort des positions, on y ajoute des sprites de bonus avec des images originales et également tirées au hasard! youpi super hahaha huhuhu hihihi
            for (NSMutableDictionary *nodule in electedBonusPositionsInMap) {
                CGPoint dasPunkt = ccp([[nodule valueForKey:@"x"] floatValue], [[nodule valueForKey:@"y"] floatValue]);
                CCSprite *newCollectibleBonusYoupiTralalaPouetPouet = [CCSprite spriteWithFile:[@"bonus_0" stringByAppendingFormat:@"%d.png",arc4random()%6+2]];
                newCollectibleBonusYoupiTralalaPouetPouet.position=dasPunkt;
                [self addChild:newCollectibleBonusYoupiTralalaPouetPouet];
                NSLog(@"Populate lesBonusDeTaMere");
                [lesBonusDeTaMere addObject:newCollectibleBonusYoupiTralalaPouetPouet];
            }
            
        }
        
        
		
        [lesBonusDeTaMere retain];
        
        // initialisation de textures
		elephantNormalTexture = [[[CCTextureCache sharedTextureCache] addImage:@"elephant-normal.png"] retain];
		elephantPukeTexture = [[[CCTextureCache sharedTextureCache] addImage:@"elephant-puke.png"] retain];	
		elephantJumpTexture = [[[CCTextureCache sharedTextureCache] addImage:@"elephant-saute.png"] retain];
        
        
        
        // initialisation des vomis de ta grand mere
        lesVomisDeTaGrandMere = [NSMutableArray array];
        [lesVomisDeTaGrandMere retain];

        
        // obtention des positions potentielles de super bonus ta mère
        CCTMXObjectGroup *obstaclesGroup = [_tileMap objectGroupNamed:@"obstacles"];
        NSMutableArray *tableauObstacles = [obstaclesGroup objects];
        nomber = [tableauObstacles count];
        
        // grande cagnotte tirage au sort parmis les positions possibles d'obstacles, pour obtenir un tableau de quelques points différents sur lesquels placer des badboys
        NSMutableArray *electedObstaclesPositionsInMap = [NSMutableArray arrayWithCapacity:9];
        lesObstaclesDeTonPere = [NSMutableArray arrayWithCapacity:9];
        for (int ii=0; ii<9; ii++) {
            int kk = arc4random() % nomber;
            [electedObstaclesPositionsInMap insertObject:[tableauObstacles objectAtIndex:kk] atIndex:ii];
            [tableauObstacles removeObjectAtIndex:kk];
            nomber--;
        }
        
        // après le tirage au sort des positions, on y ajoute des sprites de méchants connards avec des images originales et également tirées au hasard! youpi super hahaha huhuhu hihihi
        for (NSMutableDictionary *nodule in electedObstaclesPositionsInMap) {
            CGPoint dasPunkt = ccp([[nodule valueForKey:@"x"] floatValue], [[nodule valueForKey:@"y"] floatValue]);
            CCSprite *newCollidableBadBoyYoupiTralalaPouetPouet = [CCSprite spriteWithFile:[@"ennemis_0" stringByAppendingFormat:@"%d.png",arc4random()%7+1]];
            newCollidableBadBoyYoupiTralalaPouetPouet.position=dasPunkt;
            [self addChild:newCollidableBadBoyYoupiTralalaPouetPouet];
            [lesObstaclesDeTonPere addObject:newCollidableBadBoyYoupiTralalaPouetPouet];
        }
        [lesObstaclesDeTonPere retain];
        
        
		// enable events
		
		self.isTouchEnabled = YES;
		
		// init physics
		[self initPhysics];
		
		// create reset button
		//[self createMenu];
		
		//Set up sprite
        //[self initPlayer];
        
     
		// ajout de la tete de serpent
		// il est 5h23, je fais ce que je veux !
		// FIXME à ajuster
        CCSprite *serpent = [CCSprite spriteWithFile:@"serpent.png"];
        serpent.position=ccp(KLIMITLEVELUP-192.0, winSize.height/2);
        [self addChild:serpent z:10];		
		
		// taille en pixels de l'éléphant : 260px
		elephantSize = 260.0;
		currentScale = 0.4;
        // Create ball body and shape
        CCSprite *playerSprite = [CCSprite spriteWithFile:@"elephant-normal.png"];
        playerSprite.scale=currentScale;
        playerSprite.position=ccp(400, 400);
        [self addChild:playerSprite];
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(400.0/PTM_RATIO, 400.0/PTM_RATIO);
        ballBodyDef.userData = playerSprite;
        playerBody = world->CreateBody(&ballBodyDef);
        playerBody->SetUserData(playerSprite);
        //[self.sprite setPhysicsBody:body];
        
        b2CircleShape circle;
        circle.m_radius = elephantSize*playerSprite.scale/2/PTM_RATIO;
        currentCircle = &circle;
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.2f;
        ballShapeDef.restitution = 0.8f;
        playerBody->CreateFixture(&ballShapeDef);
        [self schedule:@selector(updatePlayerPosFromPhysics:)];
		[self schedule:@selector(updatePlayerSize:) interval:0.3];
        [self schedule:@selector(updateViewPoint:)];
        [self schedule:@selector(detectBonusPickup:)];
        [self schedule:@selector(updateScore:) interval:0.5];
        [self schedule:@selector(detectObstacleCollision:)];


#if 1
		// Use batch node. Faster
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
		spriteTexture_ = [parent texture];
#else
		// doesn't use batch node. Slower
		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
		CCNode *parent = [CCNode node];
#endif
		[self addChild:parent z:0 tag:kTagParentNode];
        

        particleSystem = [[CCParticleFire alloc] initWithTotalParticles:50];
        //[particleSystem setEmitterMode: kCCParticleModeRadius];
        particleSystem.startColor = (ccColor4F){200/255.f, 200/255.f, 200/255.f, 0.6f};
        particleSystem.life = 1;
        particleSystem.lifeVar = 1;
        particleSystem.angleVar = 50;
        particleSystem.startSize = 1.5;
        particleSystem.texture = [[CCTextureCache sharedTextureCache] addImage:@"player.png"];
        [self addChild:particleSystem z:10];
        
		
        [self scheduleUpdate];
	}
	return self;
}


-(void)gameover
{
	if (!hasWon) {
		[self unscheduleAllSelectors];
		[self unscheduleUpdate];
		[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [JNPBasicLayer scene:jnpGameover]]];
	}
	
}

-(void)updateScore:(float)dt
{
	JNPScore * s = [JNPScore jnpscore];
	[s incrementScore:10];
	
}

-(void)updatePlayerSize:(float)dt {
	if (fabs(currentScale) > 0.08) {
        [self diminuerPlayerDeltaScale:0.002 withEffect:NO];
		
        /*currentScale -= 0.002;
        
		if (playerBody->GetUserData() != NULL) {
            CCSprite *ballData = (CCSprite *)playerBody->GetUserData();
            ballData.scale=currentScale;
            playerBody->DestroyFixture(playerBody->GetFixtureList());
            b2CircleShape circle;
            circle.m_radius = elephantSize*currentScale/2/PTM_RATIO;
            b2FixtureDef ballShapeDef;
            ballShapeDef.shape = &circle;
            ballShapeDef.density = 0.5f * currentScale;
            ballShapeDef.friction = 0.2f;
            ballShapeDef.restitution = 0.8f;
            playerBody->CreateFixture(&ballShapeDef);
		}
         */
        
	} else {
		currentScale = 0.0;
		[self gameover];
		
	}
	
}



-(void)playerGetBiggerBecauseHeJustAteOneBonusYeahDudeYouKnow {
		currentScale += 0.15;
        
		if (playerBody->GetUserData() != NULL) {
            CCSprite *ballData = (CCSprite *)playerBody->GetUserData();
            ballData.scale=currentScale;
            playerBody->DestroyFixture(playerBody->GetFixtureList());
            b2CircleShape circle;
            circle.m_radius = elephantSize*currentScale/2/PTM_RATIO;
            b2FixtureDef ballShapeDef;
            ballShapeDef.shape = &circle;
            ballShapeDef.density = 0.5f * currentScale;
            ballShapeDef.friction = 0.2f;
            ballShapeDef.restitution = 0.8f;
            playerBody->CreateFixture(&ballShapeDef);
            
		}        

	
}




-(void)detectBonusPickup:(float)dt {
    for (CCSprite *schpritz in lesBonusDeTaMere) {
        CGPoint bonusPosition = schpritz.position;
        CGPoint playeurPosition = ((CCSprite *)playerBody->GetUserData()).position;
        CGPoint soubstraction = ccpSub(bonusPosition, playeurPosition);
        float distanceCarree = soubstraction.x * soubstraction.x + soubstraction.y * soubstraction.y;
        float dist = sqrtf(distanceCarree);
        float contentSize = ((CCSprite *)playerBody->GetUserData()).contentSize.width*((CCSprite *)playerBody->GetUserData()).scale;
        if (dist < contentSize/2 +25) {
            [self removeChild:schpritz cleanup:NO];
            [lesBonusDeTaMere removeObject:schpritz];
            [self playerGetBiggerBecauseHeJustAteOneBonusYeahDudeYouKnow];
			JNPScore * s = [JNPScore jnpscore];
			[s incrementScore:500];
            [_audioManager play:1];
            return;
        }
    }
}



-(void)detectObstacleCollision:(float)dt {
    for (CCSprite *schpritz in lesObstaclesDeTonPere) {
        CGPoint obstaclePosition = schpritz.position;
        CGPoint playeurPosition = ((CCSprite *)playerBody->GetUserData()).position;
        CGPoint soubstraction = ccpSub(obstaclePosition, playeurPosition);
        float distanceCarree = soubstraction.x * soubstraction.x + soubstraction.y * soubstraction.y;
        float dist = sqrtf(distanceCarree);
        float contentSize = ((CCSprite *)playerBody->GetUserData()).contentSize.width*((CCSprite *)playerBody->GetUserData()).scale;
        if (dist < contentSize/2 +25) {
            [self removeChild:schpritz cleanup:NO];
            [lesObstaclesDeTonPere removeObject:schpritz];
            [self diminuerPlayerDeltaScale:0.035];	
            [_audioManager play:1];
            return;
        }
    }
}



// c'est toi Soyouz !!!

-(void)updateViewPoint:(float)dt {
    float currentPlayerPosition = ((CCSprite *)playerBody->GetUserData()).position.x;
    self.position = ccp(200-currentPlayerPosition, self.position.y);
    
    float dp = currentPlayerPosition - prevPlayerPosition;
    float v = dp/dt;
    currentSpeed=v;
    
    JNPScore *s = [JNPScore jnpscore];
    float leveldifficulty = 120.0+40.0*[s getLevel];
    
    if (v<leveldifficulty) {
        float zeForce = (leveldifficulty - v)/200;
        b2Vec2 force = b2Vec2(zeForce, 0.0f);
        playerBody->ApplyLinearImpulse(force, playerBody->GetPosition());
    }
    
    if (v<KVMIN) {
        [_audioManager playMusicWithStress:1];
    } else if (v<KV2) {
        [_audioManager playMusicWithStress:2];
    } else if (v<KV3) {
        [_audioManager playMusicWithStress:3];
    } else if (v<KV4) {
        [_audioManager playMusicWithStress:4];
    } else {
        [_audioManager playMusicWithStress:5];
    }
    
    [self checkCollisions:dt];
    
    prevPlayerPosition = currentPlayerPosition;
}

-(void)updatePlayerPosFromPhysics:(float)dt {
       
	b2Body * b = playerBody;
		if (b->GetUserData() != NULL) {
            CCSprite *ballData = (CCSprite *)b->GetUserData();
            ballData.position = ccp(b->GetPosition().x * PTM_RATIO,
                                    b->GetPosition().y * PTM_RATIO);
            ballData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
			float y = b->GetPosition().y;
			float x = b->GetPosition().x;
			if (y < 0) {
				[self gameover];
			}
			
			CGSize size = [[CCDirector sharedDirector] winSize];
			
			if (y* PTM_RATIO > size.height) {
				[self gameover];
			}
			
			if (x * PTM_RATIO > KLIMITLEVELUP) {
				// on vient de passer le checkpoint !
				// empêcher le game over
				hasWon=YES;
				[controlLayer setVisible:NO];
				[controlLayer setIsTouchEnabled:NO];
				// transition vers niveau suivant (voir comment on peut faire sans tout réinitialiser
				[self unscheduleAllSelectors];
				[self unscheduleUpdate];

                JNPScore * s = [JNPScore jnpscore];
				s.vomis=lesVomisDeTaGrandMere;

				[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [JNPBasicLayer scene:jnpNewLevel]]];
			}
			
        }        
    //}
    
}

-(void)tellPlayerToJump {
    b2Vec2 force = b2Vec2(7.2f, 27.0);
    playerBody->ApplyLinearImpulse(force, playerBody->GetPosition());
	
	b2Body * b = playerBody;
	if (b->GetUserData() != NULL) {
		CCSprite *ballData = (CCSprite *)b->GetUserData();
		[ballData setTexture:elephantJumpTexture];
		[self schedule:@selector(unpuke:) interval:0.3];
	}	
}



-(void)tellPlayertoPuke:(CGPoint)position {
	//FIXME Noliv dropper un objet ici
	
	// animation
	b2Body * b = playerBody;
	if (b->GetUserData() != NULL) {
		CCSprite *ballData = (CCSprite *)b->GetUserData();
		[ballData setTexture:elephantPukeTexture];
		[self schedule:@selector(unpuke:) interval:0.3];
        
        
        
        
        // ajout du vomi !
        CGPoint dasPunkt = ccp(ballData.position.x,ballData.position.y);
        CCSprite *vomi = [CCSprite spriteWithFile:[@"bonus_0" stringByAppendingFormat:@"%d.png",arc4random()%6+2]];
        vomi.position=dasPunkt;
        [self addChild:vomi];
        NSLog(@"Populate lesVomisDeTaGrandMere");
        [lesVomisDeTaGrandMere addObject:vomi];
}

	// son
	[_audioManager playPuke];	
	
	[self diminuerPlayerDeltaScale:0.055];
    
}

-(void)diminuerPlayerDeltaScale:(float)deltaScale {
    [self diminuerPlayerDeltaScale:deltaScale withEffect:YES];
}

-(void)diminuerPlayerDeltaScale:(float)deltaScale withEffect:(Boolean)effect {
    // diminuer taille
    
    if (currentScale > deltaScale) {
        currentScale -= deltaScale;
    } else {
        currentScale = 0.1f;
    }
	
	if (playerBody->GetUserData() != NULL) {
		CCSprite *ballData = (CCSprite *)playerBody->GetUserData();
		ballData.scale=currentScale;
		playerBody->DestroyFixture(playerBody->GetFixtureList());
		b2CircleShape circle;
		circle.m_radius = elephantSize*currentScale/2/PTM_RATIO;
		b2FixtureDef ballShapeDef;
		ballShapeDef.shape = &circle;
		ballShapeDef.density = 0.5f * currentScale;
		ballShapeDef.friction = 0.2f;
		ballShapeDef.restitution = 0.8f;
		playerBody->CreateFixture(&ballShapeDef);
		if (effect) {
            playerBody->ApplyTorque(50.0);
        }
	}   
}

-(void)unpuke:(float)dt {
	b2Body * b = playerBody;
		if (b->GetUserData() != NULL) {
		CCSprite *ballData = (CCSprite *)b->GetUserData();
		[ballData setTexture:elephantNormalTexture];
	}
	[self unschedule:@selector(unpuke:)];	
}



// il y a vraiment des commentaires de merde dans ce code

-(void) dealloc
{
	delete world;
	world = NULL;
    [lesBonusDeTaMere release];
	[lesObstaclesDeTonPere release];
    [lesVomisDeTaGrandMere release];
	
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}	

// c'est toi le commentaire


-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -30.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		

    /*****************************************************************/
    
	CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"box"];
	NSMutableDictionary * objPoint;
    
	int x, y;	
	for (objPoint in [objects objects]) {
        x = [[objPoint valueForKey:@"x"] intValue];
		y = [[objPoint valueForKey:@"y"] intValue];
        
        NSString *poly = [objPoint objectForKey:@"polylinePoints"];
        NSArray *points = [poly componentsSeparatedByString:@" "];

        NSString *p1s = [points objectAtIndex:0];
        NSArray *p1 = [p1s componentsSeparatedByString:@","];
        float p1x = x + [[p1 objectAtIndex:0] floatValue];
        float p1y = y - [[p1 objectAtIndex:1] floatValue];
        
        NSString *p2s = [points objectAtIndex:1];
        NSArray *p2 = [p2s componentsSeparatedByString:@","];
        float p2x = [[p2 objectAtIndex:0] floatValue] + x;
        float p2y = y - [[p2 objectAtIndex:1] floatValue];
        
        groundBox.Set(b2Vec2(p1x/PTM_RATIO,p1y/PTM_RATIO), b2Vec2(p2x/PTM_RATIO,p2y/PTM_RATIO));
        //groundBox.Set(b2Vec2(64/PTM_RATIO,64/PTM_RATIO), b2Vec2(256/PTM_RATIO,64/PTM_RATIO));
        groundBody->CreateFixture(&groundBox,0);
        
        
    }

	// bottom
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);

    /*****************************************************************/
    // Create contact listener
    _contactListener = new MyContactListener();
    world->SetContactListener(_contactListener);
    
    
}


#pragma mark DRAW DEBUG DATA ICI !!!
-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	//world->DrawDebugData();	
	
	kmGLPopMatrix();
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
}

-(void) checkCollisions: (ccTime) dt
{
    float currentPlayerPosition = ((CCSprite *)playerBody->GetUserData()).position.x;
    
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin(); 
        pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;

        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();

        CCSprite *playerSpriteA = (CCSprite*)bodyB->GetUserData();
        
        float speedFactor = [[NSString stringWithFormat:@"%d", currentSpeed] length];
        particleSystem.sourcePosition = ccp( playerSpriteA.position.x - 450 , playerSpriteA.position.y );
        particleSystem.startSizeVar = 0.9 * speedFactor;
        particleSystem.lifeVar = 3 * speedFactor;
        particleSystem.life = 2 * speedFactor;

        // not toooooo much boingboing
        if (fabs(prevPlayerPosition - currentPlayerPosition) >= 1) {
            [_audioManager playJump];
        }

        [particleSystem resetSystem];
        
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            
            if (spriteA.tag == 1 && spriteB.tag == 2) {

            } else if (spriteA.tag == 2 && spriteB.tag == 1) {

            } 
        }        
    }
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}



-(void)setAudioManager:(JNPAudioManager *)audioM {
    _audioManager = audioM;
}


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}


@synthesize tileMap = _tileMap;
@synthesize background = _background;



@end
