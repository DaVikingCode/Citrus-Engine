Components.fla file contains several Citrus Object using Box2D and Nape ready to copy/paste in your own fla to create quickly a level via Flash Pro. The objects are defined as components.

Be careful, the className property (with package + class name) is specified into MovieClip's code.

Don't forget that you can always defined objects thanks to some code inside your MovieClip, for example:
<pre>var className = "citrus.objects.platformer.box2d.Enemy";
var params = {
	view: "characters/enemy.swf",
	leftBound: -300
}</pre>
