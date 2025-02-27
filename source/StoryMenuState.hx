package;

import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
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
import lime.net.curl.CURLCode;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;
	var bg:FlxSprite;

	var weekData:Array<Dynamic> = [
		['Tutorial'],
		['Bopeebo', 'Fresh', 'Dadbattle'],
		['Spookeez', 'South', 'Illusion'],
		['Pico', 'Philly', "Blammed"],
		['Satin Panties', "High", "Milf"],
		['Cocoa', 'Eggnog', 'Hallucination'],
	];
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, false];

	var weekCharacters:Array<String> = [
		'',
		'dad',
		'spooky',
		'pico',
		'mom',
		'parents-christmas',
		
	];

	var weekNames:Array<String> = [
		"Heatin' Up",
		"Rockstar",
		"Graveyard Shift",
		"Drop Out",
		"Popstar",
		"Thin Ice",
		
	];

	var txtWeekTitle:FlxText;

	static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var top:FlxSprite;
	var nottop:FlxSprite;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: sus", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		bg = new FlxSprite(-1300, -90);
		add(bg);
		bg.loadGraphic(Paths.image('mainMenuCity'));
		FlxTween.linearMotion(bg, -1300, -90, -600, -90, 1, true, {ease: FlxEase.expoInOut});


		grpWeekText = new FlxTypedGroup<MenuItem>();
		//var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		//add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();

		trace("Line 70");

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(10, 100, i);
			weekThing.y += (100 * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

		//	weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
				lock.visible = false;
			}
		}

		top = new FlxSprite(0, -15).loadGraphic(Paths.image("WEEK6BG")); // trolled!
		nottop = new FlxSprite(-100, 576).loadGraphic(Paths.image("WEEK6BG2"));
		trace("Line 96");

		grpWeekCharacters.add(new MenuCharacter(550, 260, 0.25, false));

		difficultySelectors = new FlxGroup();

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		txtTracklist = new FlxText(FlxG.width * 0.05, bg.x + bg.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		updateText();

		trace("Line 165");

		new FlxTimer().start(1.3, function(tmr:FlxTimer) {
			add(txtTracklist);
			// add(rankText);
			add(scoreText);
			add(txtWeekTitle);
			add(grpWeekCharacters);
			add(difficultySelectors);
			add(grpLocks);
			add(grpWeekText);
			add(top);
			add(nottop);
                        addVirtualPad(FULL, A_B);
		});


		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			CumFart.stateFrom = "freeplay";
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
			//	grpWeekCharacters.members[1].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(StringTools.replace(PlayState.storyPlaylist[0]," ", "-").toLowerCase() + diffic, StringTools.replace(PlayState.storyPlaylist[0]," ", "-").toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
		{
			curDifficulty += change;
	
			if (curDifficulty < 0)
				curDifficulty = 2;
			if (curDifficulty > 2)
				curDifficulty = 0;
	
			sprDifficulty.offset.x = 0;
	
			switch (curDifficulty)
			{
				case 0:
					sprDifficulty.animation.play('easy');
					sprDifficulty.offset.x = 20;
				case 1:
					sprDifficulty.animation.play('normal');
					sprDifficulty.offset.x = 70;
				case 2:
					sprDifficulty.animation.play('hard');
					sprDifficulty.offset.x = 20;
			}
	
			sprDifficulty.alpha = 0;
	
			// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
			sprDifficulty.y = leftArrow.y - 15;
			intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
	
			#if !switch
			intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
			#end
	
			FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
		}
	
		var lerpScore:Int = 0;
		var intendedScore:Int = 0;
	
		function changeWeek(change:Int = 0):Void
		{
			curWeek += change;
	
			if (curWeek >= weekData.length)
				curWeek = 0;
			if (curWeek < 0)
				curWeek = weekData.length - 1;
	
			var bullShit:Int = 0;
	
			for (item in grpWeekText.members)
			{
				item.targetY = bullShit - curWeek;
				if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
					item.alpha = 1;
				else
					item.alpha = 0.6;
				bullShit++;
			}
	
			FlxG.sound.play(Paths.sound('scrollMenu'));
	
			updateText();
		}
	
		function updateText()
		{
			grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek]);
	
			txtTracklist.text = "Tracks\n";
			var stringThing:Array<String> = weekData[curWeek];
	
			for (i in stringThing)
				txtTracklist.text += "\n" + i;
	
			txtTracklist.text = txtTracklist.text.toUpperCase();
	
			txtTracklist.screenCenter(X);
			txtTracklist.x -= FlxG.width * 0.35;
	
			txtTracklist.text += "\n";
	
			#if !switch
			intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
			#end
		}
}
