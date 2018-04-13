V3.2.0, Work in Progress
------------------------
- Starling updated on 2.3
- Feathers updated on 3.4.1
- Added Ash.
- Removed Away3D & AwayPhysics.
- Removed Signals (available via Ash).
- State class renamed in Scene class.
- CE' scaleFactor renamed in textureScaleFactor.
- Each CitrusObject doesn't require a name anymore.
- Starling instance has skipUnchangedFrames property set to true.
- Citrus Engine's Keyboard controller : key code constants have been removed to prevent some compilation issues. citrus.input.controllers.Keyboard.as has been renamed to citrus.input.controllers.KeyboardController.as to avoid import conflicts when setting up the keyboard actions and using flash.ui.Keyboard's key codes.
- ViewportMode.FILL
- Box2D, process contacts after world step (so we can manipulate bodies in the listeners/handle*Contact)
- CitrusObject names are optional and CitrusObject has a reference to the scene it was created from (_parentScene)
- CitrusObject has handleAddedToScene and handleRemovedFromScene 'listeners'
- SceneManager and default scene transitions
- Concurrent scenes can be individually paused, physics engines are linked to their parent scene too.
- includes EazeTween's source
- a single EazeTween can be paused/resumed
- fix for random color in MathUtils
- dynamic ViewportMode change
- StarlingArt: touchGroup = true by default (helps for basic touch control of CitrusObjects)
- Removed Blitting & display list support.

V3.1.12, 03 18 2016
-------------------
- Starling updated on 1.8
- Feathers updated on 2.3.0
- DragonBones updated on 4.1

V3.1.11, 07 24 2015
-------------------
- Starling updated on 1.7
- Feathers updated on 2.1.2
- Starling.handleLostContext is always set to true
- bug fix

V3.1.10, 09 15 2014
-------------------
- Starling updated on 1.5.1
- DragonBones updated on 3.0
- Nape updated on 2.0.16
- Feathers updated 1.3.1
- Set up SoundMixer.audioPlaybackMode to "ambient" (on iOS if the physical button is off, mute the sound).
- setUpStarling method has a stage3D argument, useful for shared context.
- Citrus has its own pausable starling juggler, AnimationSequences will be attached to it by default. When CE is paused, starling keeps running but anything attached to the citrus juggler will be paused as expected.
- CitrusSoundGroup : you can stop all sounds from a group with CitrusSoundGroup.stopAllSounds
- Camera : fixed intersects/containsRect when using rotation/zoom.
- All CitrusObjects with a view now have a reference to their actual art object.
- setUpStarling : you can force starling to run on a specific stage3D with the stage3D argument of setupStarling (used in a shared context scenario)

V3.1.9, 03 05 2014
------------------
- Feathers updated on 1.2.0
- DragonBones updated on 2.4.1
- CitrusEngine.handlePlayingChange can be overriden to modify the default behavior of CE (input resetting as well as audio pause/resume).
- LevelManager enables SWF caching, very useful on iOS. Set the new property enableSwfCaching to true.
- GamePadMap.devPlatform : force a platform value to use on setups (to simulate other platforms such as WIN/MAC/LNX/AND)
- Gamepad.debug is a static boolean.
- CitrusSoundEvents moved to citrus.events package and fixed.
- Introducing CitrusEngine.transformMatrix which when using StarlingCitrusEngine describes the transformation matrix necessary to go from native stage to starling stage (includes viewport translation as well as starling stage scale). Concatenated with the camera transform matrix, its possible to simply project a point from/to the game space to/from native stage.
- Input's action lists reset when playing changes.
- in a flash State , .swf views become spriteview.AnimationSequences
- ISpriteView.handleArtReady receives newly created art (*Art object) after view assigned or loaded from url, handleArtChanged similarly  after view changes during the game.
- APhysicsObject now has a public "animation" setter.
- AGameData is a flash Proxy class so properties can be created anytime without having to extend it (and a signal is still fired on data change). AgGameData init can be used to reset values.
- Actions : removed "duck" action for "down".
- MathUtils - added log of base N, line/segment intersection function
- Fixed/Optimized Box2DPhysicsObject's rotation
- Camera.setUp signature changed + offset became center (see wiki)
- many fixes.

V3.1.8, 11 13 2013
------------------
- Starling updated on 1.4.1
- Feathers updated on 1.1.1
- DragonBones updated to 2.4
- Nape updated on 2.0.12
- Removed Spine runtime support. Use it via DragonBones library (easier to maintain only one skeleton lib).
- Updated to latest DynamicTextureAtlas extension.
- StarlingCitrusEngine offers to manage multi-resolutions (http://wiki.starling-framework.org/citrus/multi_resolution)
- ISpriteView handleArtReady/handleArtChanged - custom citrus sprite or physics objects can now react when 'the view is set (or loaded if the view was a url) or changes' to add/remove event listeners, transform the art or manipulate its content...
- Input system : justDid,isDoing,hasDone return the corresponding InputAction object or null (instead of just true or false) // actions carry messages // introduced new utility functions such as getAction() with phase/controller/channel filtering.
- Changed the way we handle the physics engine's debug drawers (due to state transition bugs, and the new nape ShapeDebug) see APhysicsEngine.debugView
- Input : removed backwards compatibility, InputActions store the time (in frames) they spent in the Input system
- MathVector : critical bug fixes (rotate, angle) and new methods (dot product, normalize, copyFrom, setTo)
- Camera : AABB rectangle is accessible using camera.getRect()
- Camera : update call can be disabled (permanently or temporarily) using camera.enabled = false - for better peformance
- Camera : added contains(x,y) , containsRect and intersectsRect as a way to know if points/objects are on or off screen and how - for objects, use their visual bounds in state space.
- Camera : added switchToTarget() to tween camera movement and switch the camera's target value
- Camera : use center instead of offset. center defines a multiple of the screen position (1,1) meaning bottom right, to decide on the camera's center position (or formerly named offset) 0.5,0.5 being the center
- SoundManager : removeAllSounds accepts exceptions, fixed stack underflow error
- SoundManager : UI sound group added by default.
- pause/resume sounds depending Event.ACTIVATE & Event.DEACTIVATE
- AnimationSequence : removeAllAnimations method
- AnimationSequence : addTextureAtlasWithAnimations to support AssetManager objects
- using starling, an animation loaded from a .swf will be transformed into an AnimationSequence using AnimationSequence.fromMovieClip
- use addEntity instead of add to add entity to state.
- nape Platform oneWay fixed.
- box2D Reward fixed (updates by default).
- Added a LoaderContext for SpriteArt and StarlingArt, we are able to load swf on iOS.
- Added rotation parameter in TmxObject coming from latest Tiled Map Editor builds.
- Fixed a bug where using StarlingCitrusEngine we had to set it up directly.
- state.getObject* functions include results from searches in the pool objects.

V 3.1.7, 06 27 2013
-------------------
- Updated on Feathers 1.1.0.
- Updated on Nape 2.0.9.
- Updated on DragonBones 2.2.
- Added Spine 2D skeleton library support.
- Added DragonBones support for the display list.
- SoundManager reworked with a CitrusSound class and CitrusSoundGroup.
- PoolObject reworked.
- Camera reworked.
- Added a vehicle package running with Nape composed with a chassis, a driver, two wheels and some nuggets!
- Added support for pure state transition (having two state at the same time) using futureState.
- Changed the way the viewport is setup by default (based on Capabilities.playerType now).
- Starling.handleLostContext is defined to true if you use Android, made in setUpStarling function.
- if StarlingArt updateArtEnabled is set to false, it will flatten the Sprite.
- StarlingArt may handle an uint color, it will automatically create a quad.
- AnimationSequence textureAtlas could be an AssetManager object.
- You may add a MovieClip to an AnimationSequence.
- added stopAllPlayingSounds(...except) method.
- added removeAllSounds(...except) method.
- removeSound has a new argument : stopSoundIfPlaying:Boolean = false.
- Emitters have their updateCallEnabled = true;
- SoundManager fix: stream sound directly after load(); when sound was added as an url.
- fixed: stopSound wasn't setting the playing var to false.
- fixed: InputComponent wasn't setting isDoingLeft.
- fixed: updateCombinedGroundAngle() on box2d Hero
- fixed count in DoublyLinkedList if removeNode is called.
- throwing an error if the Main class doesn't extends StarlingCitrusEngine or didn't call setUpStarling

V 3.1.6, 04 18 2013
-------------------
- Updated on Nape 2.0.8
- Updated on DragonBones 2.1.1
- Mouse/Touch are disable on objects to save performances, use touchable new property to be able to interact with touch/mouse on the object. 
- Box2D contact provided by handleBeginContact, handleEndContact... uses the worldManifold instead of the local (made collision management easier).
- An entity uses a Vector to store components instead of a Dictionary.
- ObjectMakerStarling FromMovieClip's function allow to use an AssetManager object!

V 3.1.5, 04 15 2013
-------------------
- SWCs include comments!
- Added EazeTween as the default tweening engine.
- Update on DragonBones V2.0
- No more duplicated code between States class, all use the same basis: MediatorState. Now States class are just wrapper.
- When Starling is set up it picks up fullScreen dimension if it's running on mobile. The Context3DProfile parameter is also added.
- Added updateCallEnabled property to CitrusObject: This property prevent the update method to be called by the enter frame, it will save performances. Set it to true if you want to execute code in the update method.
- Added updateArtEnabled property to Art object. Set it to false if you want to prevent the art to be updated. Be careful its properties (x, y, ...) won't be able to change!
- Add physics flags to prevent running contact if not necessary (beginContactCallEnabled, endContactCallEnabled, etc.).
- Now physics is added to objects only when they are added to a state class. It's called addPhysics function. 
- ACitrusView.update has the delta time in argument (and so its children).
- Instead of a simple parallax property, now there are two: parallaxX and parallaxY
- SoundManager can handles more than 32 sounds.
- StarlingArt handles Texture view. It creates an Image.
- AnimationSequence can add new animations and remove them.
- Added a FluidBox into complex objects using ThresholdFilter, metaballs effect.
- Removed set velocity on Box2D and Nape dynamic objects since we already use a reference.
- Nape MovingPlatform's default speed is 30.
- Improved Box2D Hills.
- Fixed a bug on Nape Missile's angle.
- Prevent to add several time the same object to the state.
- Added a PolarPoint math class.
- Added an Accelerometer Input Controller.
- Added a ScreenTouch Input Controller for Starling.

V 3.1.4, 02 27 2013
-------------------
- Renamed AVirtualButtons and VirtualButtons classes into AVirtualButton and VirtualButton. Yes, they just add one button now. Easier to add many ;)
- Added Starling's simple trick to avoid the state changes (alpha 0.999).
- StarlingCitrusEngine and Away3DCitrusEngine accepts State, useful to display quickly a state with graphics from a swf, ect.
- States classes have a new method killAllObjects(...except). The _objects variable has also a getter.
- States classes have a protected variable _ce which refers to the Citrus Engine.
- Nape's Hero has a static friction removed when the player move, and set when it stops moving (to prevent sliding).
- ObjectMakerStarling has a FromMovieClip function. The second argument is the TextureAtlas. Objects made in Flash Pro can use a texture name for their view.
- Added Panning to SoundManager
- Added a camera lens parameter to view.camera.setUp function.
- Added zoomFit() to StarlingCamera and SpriteCamera
- Added a get function command for the console
- Added a trace to inform if we create a group with a high value
- view.camera.setUp returns the instance of the ACitrusCamera.
- StarlingArt doesn't generate mipmaps if view is a Bitmap.
- Added Crate object to Nape.
- Added a UI package for inventory and lifebar.
- Added a Path class which is a set of points (MathVector) that can be used with the MovingPlatform.
- Added Nape version of the Moving Platform managing also a Path if it's specified.
- Added line equation to MathUtils.
- Added linear interpolation function to MathUtils.
- Added Tools class with a print_r function to display objects and arrays content.
- Improved the Timer's cannon: it is paused if the CE is not playing.
- Added a Bridge, Rope and Pool objects, into the new objects.complex.box2dstarling package.
- Added a Multiply2 function into Box2DUtils.

V 3.1.3, 01 24 2013
-------------------
- new Camera system ready! you don't call anymore view.setupCamera function, now it is view.camera.setUp
- input uses its own update loop using Event.FRAME_CONSTRUCTED.
- fixed tiled map parser's problem where the layer index might be wrong.
- fixed a bug in Keyboard's input where some actions weren't performed.
- fixed Starling VirtualButtons and VirtualJoystick 's destroy method.
- fixed a problem with parallax when zooming.
- fixed a bug where Nape Missile's angle wasn't in radian.
- Nape's Hero no longer has a static friction.
- fixed Nape's Hero was able if the collisionAngle was really close to 0.
- moved SpriteDebugArt and StarlingSpriteDebugArt into their respective package.
- SpriteArt/StarlingArt/Away3DArt content property becomes private with a getter. It should only be set internally.

V 3.1.2, 01 17 2013
-------------------
- improved physics performance removing the update call to the debug view if it isn't visible.
- outsourced camera stuff into a ACitrusCamera class and one camera by view : BlittingCamera, SpriteCamera, StarlingCamera and Away3DCamera2D.
- renamed CitrusView into ACitrusView class.
- addSound method has now two arguments : the id (String) and the sound (*, String or Class).
- added CitrusGroup class to group different kind of objects.
- added createAABB method in MathUtils package.
- added CollisionGetObjectByType into Box2DUtils and NapeUtils.
- added getObjectsByName method.
- added a fla with Citrus objects components to create quickly objects using Flash Pro as a level editor.
- you can change physics step thanks to their public var.
- updated on Starling 1.3.
- fixed a bug where the group property wasn't updated using Away3DView, SpriteView and StarlingView.
- fixed on StarlingArt, the object's view changed but animation doesn't update on the new view.

V 3.1.1, 12 20 2012
-------------------
- created starling and away3d package in citrus.core for StarlingCitrusEngine, StarlingState, Away3DCitrusEngine and Away3DState classes.
- removed stage argument in setUpStarling function, override the handleAddedToStage method to call setUpStarling function instead.
- added Nape parser for polygon/polyline.
- AVirtualJoystick : action value scaling.
- TimeShifter now listens to and routes input to his defaultChannel which remains channel 16 when instanciated.
- fixed a bug where Starling couldn't dispose.
- fixed a bug on TimeShifter using params.
- fixed camera offset for BlittingView.

V 3.1.0, 12 14 2012
-------------------
- Renamed package "com" and "citrusengine" into "citrus".
- The LevelManager can load levels made with Flash Pro on iOS using a LoaderContext.
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
- Update on Starling RC 1.3 + added its new AssetManager class.
- StarlingArt is now able to dispose automatically basic DisplayObject.
- Starling's AnimationSequence has a clone method.
- Starling's AnimationSequence dispatch onAnimationComplete Signal

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
