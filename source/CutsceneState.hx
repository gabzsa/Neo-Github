package;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import openfl.Lib;

class CutsceneState extends MusicBeatState
{
	var _goodEnding:Bool = false;

	var zoom:Float = -1;
	
	public function new(goodEnding:Bool = true) 
	{
		super();
		_goodEnding = goodEnding;
		
	}
	
	override public function create():Void 
	{
		trace(PlayState.storyWeek);
		super.create();	
		if (PlayState.storyWeek == 0)
			endIt();
		if (PlayState.storyWeek == 1)
			endIt();
		if (PlayState.storyWeek == 2)
			endIt();
		if (PlayState.storyWeek == 3)
			endIt();
		if (PlayState.storyWeek == 4)
			endIt();
		else
		        FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
			if (PlayState.storyWeek == 5)
                                var video = new FlxVideo(SUtil.getPath() + Paths.video('CutsceneFinal'));
				video.finishCallback = function()
				{
					FlxG.switchState(new StoryMenuState());							
				}
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
	
	public function endIt(e:FlxTimer=null){
		trace("ENDING");
		FlxG.switchState(new PlayState());
	}
	
}
