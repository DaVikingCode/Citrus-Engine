![](http://aymericlamboley.fr/blog/wp-content/uploads/2012/08/citrus.png)

The [Citrus Engine](http://citrusengine.com/) is a professional-grade, scalable Flash game engine built for industry-quality games. It is built upon modern Flash programming practices, allowing you to focus on making your game awesome! It comes built-in with a "platformer" starter-kit, which you can use to easily make awesome 2D sidescrolling games.

It offers many options, you may use :
- the classic flash display list, or blitting or Stage3D thanks to [Starling](http://gamua.com/starling/).
- [Box2D](http://www.box2d.org/manual.html), or [Nape](http://deltaluca.me.uk/docnew/) or a Simple math based collision detection.
- a simple way to manage object creation, and for advanced developers : an entity/component system and object pooling.
- a LevelManager and LoadManager which may use Flash Pro as a level editor.

Games
-----
[![Kinessia](http://aymericlamboley.fr/blog/wp-content/uploads/2012/08/Kinessia.jpg)](http://kinessia.aymericlamboley.fr/)
[![MarcoPoloWeltrennen](http://aymericlamboley.fr/blog/wp-content/uploads/2012/08/MarcoPoloWeltrennen.png)](http://www.marcopoloweltrennen.de/)

Project Setup
-------------
- bin : pictures, animations, levels, ... loaded at runtime.
- embed : embedded assets (e.g. fonts, pictures, texture atlas, ...).
- fla : two levels used in the box2dstarling demo, and two animate characters (set up to be loaded by the dynamic texture atlas, the fla is different from the one loaded at runtime in the SpriteArt ; take a look on the CE V2 for this one).
- libs : all the libs used, included the Citrus Engine. Select just one Nape swc.
- src : different demos ready to use! You just need to copy & paste the Main from the package you want into the src/Main.as and the demo will run. Be careful with package & import.