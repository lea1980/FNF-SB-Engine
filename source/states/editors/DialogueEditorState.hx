package states.editors;

#if desktop
import backend.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
#if android
import android.flixel.FlxButton;
#else
import flixel.ui.FlxButton;
#end
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flash.net.FileFilter;
import haxe.Json;
import cutscenes.DialogueBoxPsych;
import lime.system.Clipboard;
import objects.Alphabet;
import objects.TypedAlphabet;
import lime.app.Application;
#if sys
import sys.io.File;
#end
import backend.ClientPrefs;
import backend.MusicBeatState;
import backend.Paths;
import states.MainMenuState;
import states.editors.MasterEditorMenu;

using StringTools;

class DialogueEditorState extends MusicBeatState {
	var character:DialogueCharacter;
	var box:FlxSprite;
	var daText:TypedAlphabet;

	var selectedText:FlxText;
	var animationText:FlxText;

	var defaultLine:DialogueLine;
	var dialogueFile:DialogueFile = null;

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		FlxG.camera.bgColor = FlxColor.fromHSL(0, 0, 0.5);

		defaultLine = {
			portrait: DialogueCharacter.DEFAULT_CHARACTER,
			expression: 'talk',
			text: DEFAULT_TEXT,
			boxState: DEFAULT_BUBBLETYPE,
			speed: 0.05,
			sound: ''
		};

		dialogueFile = {
			dialogue: [copyDefaultLine()]
		};

		character = new DialogueCharacter();
		character.scrollFactor.set();
		add(character);

		box = new FlxSprite(70, 370);
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.antialiasing = ClientPrefs.globalAntialiasing;
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		box.animation.addByPrefix('center', 'speech bubble middle', 24);
		box.animation.addByPrefix('center-angry', 'AHH Speech Bubble middle', 24);
		box.animation.play('normal', true);
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		add(box);

		addEditorBox();
		#if android
		FlxG.mouse.visible = false;
		#else
		FlxG.mouse.visible = true;
		#end

		#if !android
		var addLineText:FlxText = new FlxText(10, 10, FlxG.width - 20,
			'Press O to remove the current dialogue line, Press P to add another line after the current one.', 8);
		#else
		var addLineText:FlxText = new FlxText(10, 10, FlxG.width - 20,
			'Press A Button to remove the current dialogue line, Press B Button to add another line after the current one.', 8);
		#end
		switch (ClientPrefs.gameStyle) {
			case 'SB Engine':
			    addLineText.setFormat("Bahnschrift", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

            case 'Psych Engine':
			    addLineText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			case 'Better UI':
			    addLineText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			case 'Forever Engine':
			    addLineText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			case 'Grafex Engine':
			    addLineText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		addLineText.scrollFactor.set();
		add(addLineText);

		selectedText = new FlxText(10, 32, FlxG.width - 20, '', 8);
		switch (ClientPrefs.gameStyle) {
			case 'SB Engine':
			    selectedText.setFormat("Bahnschrift", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

            case 'Psych Engine':
			    selectedText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			case 'Better UI':
			    selectedText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			case 'Forever Engine':
			    selectedText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			case 'Grafex Engine':
			    selectedText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		selectedText.scrollFactor.set();
		add(selectedText);

		animationText = new FlxText(10, 62, FlxG.width - 20, '', 8);
		switch (ClientPrefs.gameStyle) {
			case 'SB Engine':
			    animationText.setFormat("Bahnschrift", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

            case 'Psych Engine':
			    animationText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			case 'Better UI':
			    animationText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			case 'Forever Engine':
			    animationText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			case 'Grafex Engine':
			    animationText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		animationText.scrollFactor.set();
		add(animationText);

		daText = new TypedAlphabet(DialogueBoxPsych.DEFAULT_TEXT_X, DialogueBoxPsych.DEFAULT_TEXT_Y, DEFAULT_TEXT);
		daText.scaleX = 0.7;
		daText.scaleY = 0.7;
		add(daText);
		changeText();

		#if android
		addVirtualPad(LEFT_FULL, A_B_C);
		#end

		super.create();
	}

	var UI_box:FlxUITabMenu;

	function addEditorBox() {
		var tabs = [{name: 'Dialogue Line', label: 'Dialogue Line'},];
		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(250, 210);
		UI_box.x = FlxG.width - UI_box.width - 10;
		UI_box.y = 10;
		UI_box.scrollFactor.set();
		UI_box.alpha = 0.8;
		addDialogueLineUI();
		add(UI_box);
	}

	var characterInputText:FlxUIInputText;
	var lineInputText:FlxUIInputText;
	var angryCheckbox:FlxUICheckBox;
	var speedStepper:FlxUINumericStepper;
	var soundInputText:FlxUIInputText;

	function addDialogueLineUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Dialogue Line";

		characterInputText = new FlxUIInputText(10, 20, 80, DialogueCharacter.DEFAULT_CHARACTER, 8);
		characterInputText.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		blockPressWhileTypingOn.push(characterInputText);

		speedStepper = new FlxUINumericStepper(10, characterInputText.y + 40, 0.005, 0.05, 0, 0.5, 3);

		angryCheckbox = new FlxUICheckBox(speedStepper.x + 120, speedStepper.y, null, null, "Angry Textbox", 200);
		angryCheckbox.callback = function() {
			updateTextBox();
			dialogueFile.dialogue[currentlySelected].boxState = (angryCheckbox.checked ? 'angry' : 'normal');
		};

		soundInputText = new FlxUIInputText(10, speedStepper.y + 40, 150, '', 8);
		soundInputText.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		blockPressWhileTypingOn.push(soundInputText);

		lineInputText = new FlxUIInputText(10, soundInputText.y + 35, 200, DEFAULT_TEXT, 8);
		lineInputText.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		blockPressWhileTypingOn.push(lineInputText);

		#if !android
		var loadButton:FlxButton = new FlxButton(20, lineInputText.y + 25, "Load Dialogue", function() {
			loadDialogue();
		});
		var saveButton:FlxButton = new FlxButton(loadButton.x + 120, loadButton.y, "Save Dialogue", function() {
			saveDialogue();
		});
		#else
		var saveButton:FlxButton = new FlxButton(20, lineInputText.y + 25, "Save Dialogue", function() {
			saveDialogue();
		});
		#end

		tab_group.add(new FlxText(10, speedStepper.y - 18, 0, 'Interval/Speed (ms):'));
		tab_group.add(new FlxText(10, characterInputText.y - 18, 0, 'Character:'));
		tab_group.add(new FlxText(10, soundInputText.y - 18, 0, 'Sound file name:'));
		tab_group.add(new FlxText(10, lineInputText.y - 18, 0, 'Text:'));
		tab_group.add(characterInputText);
		tab_group.add(angryCheckbox);
		tab_group.add(speedStepper);
		tab_group.add(soundInputText);
		tab_group.add(lineInputText);
		#if !android
		tab_group.add(loadButton);
		#end
		tab_group.add(saveButton);
		UI_box.addGroup(tab_group);
	}

	function copyDefaultLine():DialogueLine {
		var copyLine:DialogueLine = {
			portrait: defaultLine.portrait,
			expression: defaultLine.expression,
			text: defaultLine.text,
			boxState: defaultLine.boxState,
			speed: defaultLine.speed,
			sound: ''
		};
		return copyLine;
	}

	function updateTextBox() {
		box.flipX = false;
		var isAngry:Bool = angryCheckbox.checked;
		var anim:String = isAngry ? 'angry' : 'normal';

		switch (character.jsonFile.dialogue_pos) {
			case 'left':
				box.flipX = true;
			case 'center':
				if (isAngry) {
					anim = 'center-angry';
				} else {
					anim = 'center';
				}
		}
		box.animation.play(anim, true);
		DialogueBoxPsych.updateBoxOffsets(box);
	}

	function reloadCharacter() {
		character.frames = Paths.getSparrowAtlas('dialogue/' + character.jsonFile.image);
		character.jsonFile = character.jsonFile;
		character.reloadAnimations();
		character.setGraphicSize(Std.int(character.width * DialogueCharacter.DEFAULT_SCALE * character.jsonFile.scale));
		character.updateHitbox();
		character.x = DialogueBoxPsych.LEFT_CHAR_X;
		character.y = DialogueBoxPsych.DEFAULT_CHAR_Y;

		switch (character.jsonFile.dialogue_pos) {
			case 'right':
				character.x = FlxG.width - character.width + DialogueBoxPsych.RIGHT_CHAR_X;

			case 'center':
				character.x = FlxG.width / 2;
				character.x -= character.width / 2;
		}
		character.x += character.jsonFile.position[0];
		character.y += character.jsonFile.position[1];
		character.playAnim(); // Plays random animation
		characterAnimSpeed();

		if (character.animation.curAnim != null && character.jsonFile.animations != null) {
			#if !android
			animationText.text = 'Animation: '
				+ character.jsonFile.animations[curAnim].anim
					+ ' ('
					+ (curAnim + 1)
					+ ' / '
					+ character.jsonFile.animations.length
					+ ') - Press W or S to scroll';
			#else
			animationText.text = 'Animation: '
				+ character.jsonFile.animations[curAnim].anim
					+ ' ('
					+ (curAnim + 1)
					+ ' / '
					+ character.jsonFile.animations.length
					+ ') - Press Up or Down Button to scroll';
			#end
		} else {
			animationText.text = 'ERROR! NO ANIMATIONS FOUND';
		}
	}

	private static var DEFAULT_TEXT:String = "coolswag";
	private static var DEFAULT_SPEED:Float = 0.05;
	private static var DEFAULT_BUBBLETYPE:String = "normal";

	function reloadText(skipDialogue:Bool) {
		var textToType:String = lineInputText.text;
		if (textToType == null || textToType.length < 1)
			textToType = ' ';

		daText.text = textToType;
		daText.resetDialogue();

		if (skipDialogue)
			daText.finishText();
		else if (daText.delay > 0) {
			if (character.jsonFile.animations.length > curAnim && character.jsonFile.animations[curAnim] != null) {
				character.playAnim(character.jsonFile.animations[curAnim].anim);
			}
			characterAnimSpeed();
		}

		daText.y = DialogueBoxPsych.DEFAULT_TEXT_Y;
		if (daText.rows > 2)
			daText.y -= DialogueBoxPsych.LONG_TEXT_ADD;

		#if desktop
		// Updating Discord Rich Presence
		var rpcText:String = lineInputText.text;
		if (rpcText == null || rpcText.length < 1)
			rpcText = '(Empty)';
		if (rpcText.length < 3)
			rpcText += '   '; // Fixes a bug on RPC that triggers an error when the text is too short
		DiscordClient.changePresence("Dialogue Editor", rpcText);
		#end
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if (sender == characterInputText) {
				character.reloadCharacterJson(characterInputText.text);
				reloadCharacter();
				if (character.jsonFile.animations.length > 0) {
					curAnim = 0;
					if (character.jsonFile.animations.length > curAnim && character.jsonFile.animations[curAnim] != null) {
						character.playAnim(character.jsonFile.animations[curAnim].anim, daText.finishedText);
						#if !android
						animationText.text = 'Animation: '
							+ character.jsonFile.animations[curAnim].anim
								+ ' ('
								+ (curAnim + 1)
								+ ' / '
								+ character.jsonFile.animations.length
								+ ') - Press W or S to scroll';
						#else
						animationText.text = 'Animation: '
							+ character.jsonFile.animations[curAnim].anim
								+ ' ('
								+ (curAnim + 1)
								+ ' / '
								+ character.jsonFile.animations.length
								+ ') - Press Up or Down Button to scroll';
						#end
					} else {
						animationText.text = 'ERROR! NO ANIMATIONS FOUND';
					}
					characterAnimSpeed();
				}
				dialogueFile.dialogue[currentlySelected].portrait = characterInputText.text;
				reloadText(false);
				updateTextBox();
			} else if (sender == lineInputText) {
				dialogueFile.dialogue[currentlySelected].text = lineInputText.text;

				daText.text = lineInputText.text;
				if (daText.text == null)
					daText.text = '';
				reloadText(true);
			} else if (sender == soundInputText) {
				daText.finishText();
				dialogueFile.dialogue[currentlySelected].sound = soundInputText.text;
				daText.sound = soundInputText.text;
				if (daText.sound == null)
					daText.sound = '';
			}
		} else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender == speedStepper)) {
			dialogueFile.dialogue[currentlySelected].speed = speedStepper.value;
			if (Math.isNaN(dialogueFile.dialogue[currentlySelected].speed)
				|| dialogueFile.dialogue[currentlySelected].speed == null
				|| dialogueFile.dialogue[currentlySelected].speed < 0.001) {
				dialogueFile.dialogue[currentlySelected].speed = 0.0;
			}
			daText.delay = dialogueFile.dialogue[currentlySelected].speed;
			reloadText(false);
		}
	}

	var currentlySelected:Int = 0;
	var curAnim:Int = 0;
	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	var transitioning:Bool = false;

	override function update(elapsed:Float) {
		if (transitioning) {
			super.update(elapsed);
			return;
		}

		if (character.animation.curAnim != null) {
			if (daText.finishedText) {
				if (character.animationIsLoop() && character.animation.curAnim.finished) {
					character.playAnim(character.animation.curAnim.name, true);
				}
			} else if (character.animation.curAnim.finished) {
				character.animation.curAnim.restart();
			}
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if (inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;

				if (FlxG.keys.justPressed.ENTER) {
					if (inputText == lineInputText) {
						inputText.text += '\\n';
						inputText.caretIndex += 2;
					} else {
						inputText.hasFocus = false;
					}
				}
				break;
			}
		}

		if (!blockInput) {
			FlxG.sound.muteKeys = states.TitleScreenState.muteKeys;
			FlxG.sound.volumeDownKeys = states.TitleScreenState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = states.TitleScreenState.volumeUpKeys;
			if (#if !android FlxG.keys.justPressed.SPACE #else virtualPad.buttonC.justPressed #end) {
				reloadText(false);
			}
			if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justReleased.BACK #end) {
				MusicBeatState.switchState(new states.editors.MasterEditorMenu());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + states.MainMenuState.sbEngineVersion + " - Mod Maker Menu";
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
				transitioning = true;
			}
			var negaMult:Array<Int> = [1, -1];
			var controlAnim:Array<Bool> = [
				#if !android FlxG.keys.justPressed.W #else virtualPad.buttonUp.justPressed #end,
				#if !android FlxG.keys.justPressed.S #else virtualPad.buttonDown.justPressed #end
			];
			var controlText:Array<Bool> = [
				#if !android FlxG.keys.justPressed.D #else virtualPad.buttonLeft.justPressed #end,
				#if !android FlxG.keys.justPressed.A #else virtualPad.buttonRight.justPressed #end
			];
			for (i in 0...controlAnim.length) {
				if (controlAnim[i] && character.jsonFile.animations.length > 0) {
					curAnim -= negaMult[i];
					if (curAnim < 0)
						curAnim = character.jsonFile.animations.length - 1;
					else if (curAnim >= character.jsonFile.animations.length)
						curAnim = 0;

					var animationToPlay:String = character.jsonFile.animations[curAnim].anim;
					if (character.dialogueAnimations.exists(animationToPlay)) {
						character.playAnim(animationToPlay, daText.finishedText);
						dialogueFile.dialogue[currentlySelected].expression = animationToPlay;
					}
					#if !android
					animationText.text = 'Animation: ' + animationToPlay + ' (' + (curAnim + 1) + ' / ' + character.jsonFile.animations.length
						+ ') - Press W or S to scroll';
					#else
					animationText.text = 'Animation: ' + animationToPlay + ' (' + (curAnim + 1) + ' / ' + character.jsonFile.animations.length
						+ ') - Press Up or Down Button to scroll';
					#end
				}
				if (controlText[i]) {
					changeText(negaMult[i]);
				}
			}

			if (FlxG.keys.justPressed.O #if android || virtualPad.buttonA.justPressed #end) {
				dialogueFile.dialogue.remove(dialogueFile.dialogue[currentlySelected]);
				if (dialogueFile.dialogue.length < 1) // You deleted everything, dumbo!
				{
					dialogueFile.dialogue = [copyDefaultLine()];
				}
				changeText();
			} else if (FlxG.keys.justPressed.P #if android || virtualPad.buttonB.justPressed #end) {
				dialogueFile.dialogue.insert(currentlySelected + 1, copyDefaultLine());
				changeText(1);
			}
		}
		super.update(elapsed);
	}

	function changeText(add:Int = 0) {
		currentlySelected += add;
		if (currentlySelected < 0)
			currentlySelected = dialogueFile.dialogue.length - 1;
		else if (currentlySelected >= dialogueFile.dialogue.length)
			currentlySelected = 0;

		var curDialogue:DialogueLine = dialogueFile.dialogue[currentlySelected];
		characterInputText.text = curDialogue.portrait;
		lineInputText.text = curDialogue.text;
		angryCheckbox.checked = (curDialogue.boxState == 'angry');
		speedStepper.value = curDialogue.speed;

		if (curDialogue.sound == null)
			curDialogue.sound = '';
		soundInputText.text = curDialogue.sound;

		daText.delay = speedStepper.value;
		daText.sound = soundInputText.text;
		if (daText.sound != null && daText.sound.trim() == '')
			daText.sound = 'dialogue';

		curAnim = 0;
		character.reloadCharacterJson(characterInputText.text);
		reloadCharacter();
		reloadText(false);
		updateTextBox();

		var leLength:Int = character.jsonFile.animations.length;
		if (leLength > 0) {
			for (i in 0...leLength) {
				var leAnim:DialogueAnimArray = character.jsonFile.animations[i];
				if (leAnim != null && leAnim.anim == curDialogue.expression) {
					curAnim = i;
					break;
				}
			}
			character.playAnim(character.jsonFile.animations[curAnim].anim, daText.finishedText);
			#if !android
			animationText.text = 'Animation: '
				+ character.jsonFile.animations[curAnim].anim
					+ ' ('
					+ (curAnim + 1)
					+ ' / '
					+ leLength
					+ ') - Press W or S to scroll';
			#else
			animationText.text = 'Animation: '
				+ character.jsonFile.animations[curAnim].anim
					+ ' ('
					+ (curAnim + 1)
					+ ' / '
					+ leLength
					+ ') - Press Up or Down Button to scroll';
			#end
		} else {
			animationText.text = 'ERROR! NO ANIMATIONS FOUND';
		}
		characterAnimSpeed();

		#if !android
		selectedText.text = 'Line: (' + (currentlySelected + 1) + ' / ' + dialogueFile.dialogue.length + ') - Press A or D to scroll';
		#else
		selectedText.text = 'Line: (' + (currentlySelected + 1) + ' / ' + dialogueFile.dialogue.length + ') - Press Left or Right Button to scroll';
		#end
	}

	function characterAnimSpeed() {
		if (character.animation.curAnim != null) {
			var speed:Float = speedStepper.value;
			var rate:Float = 24 - (((speed - 0.05) / 5) * 480);
			if (rate < 12)
				rate = 12;
			else if (rate > 48)
				rate = 48;
			character.animation.curAnim.frameRate = rate;
		}
	}

	var _file:FileReference = null;

	function loadDialogue() {
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	function onLoadComplete(_):Void {
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if (_file.__path != null)
			fullPath = _file.__path;

		if (fullPath != null) {
			var rawJson:String = File.getContent(fullPath);
			if (rawJson != null) {
				var loadedDialog:DialogueFile = cast Json.parse(rawJson);
				if (loadedDialog.dialogue != null && loadedDialog.dialogue.length > 0) // Make sure it's really a dialogue file
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					trace("Successfully loaded file: " + cutName);
					dialogueFile = loadedDialog;
					changeText();
					_file = null;
					return;
				}
			}
		}
		_file = null;
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onLoadCancel(_):Void {
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onLoadError(_):Void {
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

	function saveDialogue() {
		var data:String = Json.stringify(dialogueFile, "\t");
		if (data.length > 0) {
			#if android
			SUtil.saveContent("dialogue", ".json", data);
			#else
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, "dialogue.json");
			#end
		}
	}

	function onSaveComplete(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}
}
