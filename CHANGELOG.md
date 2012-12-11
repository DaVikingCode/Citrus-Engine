V 3.1.0, Work in progress
-------------------------
- The setUpStarling function may take the flash stage as an argument (useful if not the root class).
- AnimationSequence's dictionary is now accessible thanks to a getter.
- Changed _input to protected to allow custom Input.
- Added the new input package supporting keyboard, joystick, button, channel, key action...
- Added a TimeShifter à la Braid! Allow also to replay an action.
- Upgraded on Nape 2.0.
- Nape's gravity is equal to Box2D's gravity.
- Nape's object physics behavior are closed to Box2d one (friction, speed, hero & enemy interaction...)
- refreshPoolObjectArt handles the startIndex.
- Now we can easily read the velocity of a body thanks to a getter.
- Thanks to ObjectMaker we can define vertices using Tiled Map Editor software.
- StarlingArt is now able to dispose automatically basic DisplayObject.

V 3.0.4, 11 29 2012
-------------------
- DragonBones support for StarlingArt class.
- Moved ObjectMaker2D & 3D classes and tmx package into a new objectmakers package.
- Create a new ObjectMakerStarling class with a parser for Tiled Map Editor’s files optimized for Starling. 

V 3.0.3, 11 28 2012
-------------------
- optimized MathVector class.
- a PoolObject can be rendered through the State/StarlingState classes.
- the LevelManager class can load tmx file.
- ATF file format are supported by the StarlingTileSystem class.
- tiled map objectmaker uses dynamic tileset name.
- ObjectMaker FromTiledMap support now multipe tileSets.
- added a RevolvingPlatform in box2d platformer’s package.
- the Starling’s AnimationSequence class has a new parameter : the smoothing. Default is bilinear.

V 3.0.2, 11 20 2012
-------------------
- fixed a bug where the MovingPlatform speed parameters wasn’t applied.
- fixed a critical bug using Android where the state could be instantiated before the context3D is created.
- fixed a bug if a flash display object was added using StarlingState, there were a problem destroying the state due to the physics debug view.
- the entity/component system works fine now with Box2D pure AS3 and enable interaction with “normal” object.
- all Box2D objects implements the IBox2DPhysicsObject interface.
- CollisionGetOther CollisionGetSelf Rotateb2Vec2 functions have moved into a new class : Box2DUtils
- Box2DShapeMaker class moved into physics/box2d package

V 3.0.1, 11 16 2012
-------------------
- fixed a bug on Nape’s Hero colliding with a Sensor.
- fixed a bug where the Box2D Hero was able to double jump thanks to a Sensor or a Cloud.
- fixed a bug where a passenger falls on a Moving Platform if it changes direction to downward.
- optimizing States loops.
- an Enemy doesn’t move anymore during the period it is hurt (don’t forget it is killed after this period).
- Hero switches facing direction while in mid-air.
- DistanceBetweenTwoPoints method added in MathUtils.
- CitrusEngine’s handleAddedToStage method is now protected.
- Adding auto setting of a component’s entity when adding to an entity, also added 2 utilites that search for a component by class type.
- Frame Rate Independent Motion support added!

V 3.0.0, 11 6 2012
------------------
- Moved from Box2D Alchemy to Box2D pure AS3 for better performance
- Starling support
- Nape physics engine supported with some pre-built platformer objects
- Level Manager and an abstract game data class
- Object Pooling and Entity/Component System
- Away3D support
- AwayPhysics support
- New Level Editor handlers for: Tiled Map and Cadet 3D.
- Lots of examples with assets
- A new forum on Starling’s website
- Other cool features and performance improvement