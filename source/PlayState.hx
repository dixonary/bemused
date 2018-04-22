package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
using flixel.tweens.FlxTween;
import flixel.text.FlxText;
using flixel.util.FlxSpriteUtil;
import flixel.system.FlxSound;
import openfl.display.StageQuality;
import flixel.util.FlxTimer;
import extension.screenshot.Screenshot;
import extension.share.Share;

class PlayState extends FlxState
{

    var authors:Array<String> = [
        "Leonardo","Vincent","Raphael",
        "Pablo", "Vermeer", "Michelangelo"];
    var topText:FlxText;
    var topText2:FlxText;
    var board:SwapBoard;
    var timer:FlxSprite;
    var timerBits:Array<FlxSprite>;
    public static var time:Float = 0;
    var fullTime:Float = 101;
    var timerText:FlxText;
    var started:Bool = false;
    var author:String;
    var anotherBtn:AnotherBtn;
    public static var fader:FlxSprite;

    override public function create():Void
    {
        super.create();
        time=0;
        author = Random.fromArray(authors);

        FlxG.cameras.bgColor = 0xff806837;
        FlxG.stage.quality = StageQuality.BEST;

        var bg = new FlxSprite(0,0,"assets/images/wood.jpg");
        bg.alpha = 0.2;
        bg.scale.x = FlxG.width/bg.width;
        bg.scale.y = FlxG.height/bg.height;
        bg.updateHitbox();
        add(bg);
        
        var painting = new FlxSprite(0,0,'assets/images/paintings/$author.jpg');

        var pW;
        var pH;
        if(painting.height / painting.width > 1.5) {
            pH = Std.int(FlxG.width*0.6);
            pW = Std.int(pH * painting.width / painting.height);
        }
        else {
            pW = Std.int(FlxG.width*0.4);
            pH = Std.int(pW*painting.height/painting.width);
        }

        var boardW:Int = Std.int(pW);
        var boardH:Int = Std.int(pH);
        add(board=new SwapBoard(boardW,boardH,9,9));


        painting.scale.x = pW/painting.width;
        painting.scale.y = painting.scale.x;
        painting.updateHitbox();

        painting.x = FlxG.width*0.75-pW/2;
        painting.y = FlxG.height*0.55 - pH/2;

        board.x = FlxG.width*0.25-pW/2;
        board.y = FlxG.height*0.55 - pH/2;

        var surr = new Surround(Std.int(pW),Std.int(pH),5,0xff402001);
        surr.x = painting.x-5;
        surr.y = painting.y-5;
        add(surr);

        var surr = new Surround(Std.int(pW),Std.int(pH),5,0xff402001);
        surr.x = board.x-5;
        surr.y = board.y-5;
        add(surr);

        add(painting);


        var painting_blur = new FlxSprite(0,0,'assets/images/blurs/$author.jpg');

        var count = 0;
        var colors = [];
        for(i in 0...board.tilesW) {
            for(j in 0...board.tilesH) {
                var col = painting_blur.pixels.getPixel(
                    Std.int((i+0.5)/board.tilesW*painting.pixels.width),
                    Std.int((j+0.5)/board.tilesH*painting.pixels.height)        
                );
                board.pieces[count++].color = col;
//                colors.push(col);
            }
        }

        // reset for spritegroup reasons
        board.x = board.y = 0;

        // Shuffle
        Random.shuffle(board.pieces);
        count=0;
        for(i in 0...board.tilesW) {
            for(j in 0...board.tilesH) {
                var p = board.pieces[count];
                p.pX = i;
                p.pY = j;
                p.homeX = p.x = Std.int(i*board.Width/board.tilesW);
                p.homeY = p.y = Std.int(j*board.Height/board.tilesH);
                count++;
            }
        }

        board.x = FlxG.width*0.25-pW/2;
        board.y = FlxG.height*0.55 - pH/2;

        /*
        count=0;
        var quantizedColors = Clustering.ColorQuantize(colors);

        for(i in 0...board.tilesW) {
            for(j in 0...board.tilesH) {
                var col = painting_blur.pixels.getPixel(
                    Std.int((i+0.5)/board.tilesW*painting.pixels.width),
                    Std.int((j+0.5)/board.tilesH*painting.pixels.height)        
                );
                board.pieces[count++].color = quantizedColors[col];
            }
        }
        */
        
        
        fader = new FlxSprite();
        fader.makeGraphic(1,1,0xffffffff);
        fader.scale.x = FlxG.width;
        fader.scale.y = FlxG.height;
        fader.updateHitbox();
        fader.tween({alpha:0},1,{onComplete:function(t) {

        }});

        topText = new FlxText(0,10,FlxG.width,
            "Recreate the image on the right.\nYou will have just under two minutes.");
        topText.setFormat("assets/bop.ttf",24,0xff804003,CENTER);
        topText2 = new FlxText(1,11,FlxG.width,
            "Recreate the image on the right.\nYou will have just under two minutes.");
        topText2.setFormat("assets/bop.ttf",24,0xff402001,CENTER);
        topText.visible=false;
        add(topText2);
        add(topText);

        anotherBtn = new AnotherBtn();
        anotherBtn.x = FlxG.width-anotherBtn.bg.width-10;
        anotherBtn.y = 10;
        add(anotherBtn);

        add(fader);
    }

    public function startTimer() {
        if(started) return;

        timerBits = [];
        var topSize = FlxG.height*0.1;
        
        timer = new FlxSprite();
        timer.makeGraphic(1,1,0xff402001);
        timer.scale.x = FlxG.width;
        timer.scale.y = topSize;
        timer.origin.set(0,0);
        timer.x=0;
        timer.y=0;
        timer.alpha=0;
        timer.tween({alpha:1},1);
        add(timer);
        timerBits.push(timer);

        timer = new FlxSprite(0,0,"assets/images/wood.jpg");
        timer.scale.x = FlxG.width/timer.width;
        timer.scale.y = topSize/timer.height;
        timer.origin.set(0,0);
        timer.x=0;
        timer.y=0;
        timer.alpha=0;
        timer.tween({alpha:0.2},1);
        add(timer);
        timerBits.push(timer);

        
        timer = new FlxSprite();
        timer.makeGraphic(1,1,0x77804003);
        timer.scale.x = FlxG.width;
        timer.scale.y = topSize;
        timer.origin.set(0,0);
        timer.x=0;
        timer.y=0;
        timer.alpha=0;
        timer.tween({alpha:1},1);
        add(timer);
        timerBits.push(timer);

        var t = new FlxSprite(0,topSize-4)
                    .makeGraphic(FlxG.width,4,0xff000000);
        add(t);
        timerBits.push(t);
        t.alpha=0;
        t.tween({alpha:1},1);

        started = true;
        time = fullTime;

        new FlxSound().loadEmbedded("assets/music/minutewaltz.ogg").play();

        topText.tween({alpha:0},1);
        topText2.tween({alpha:0},1);

        timerText = new FlxText(15,0,FlxG.width,"");
        timerText.setFormat("assets/ChopinScript.otf",40,0xffffffff);
        add(timerText);
        timerBits.push(timerText);

        anotherBtn.tween({alpha:0.001},1);


    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(started) {
            time -= elapsed;

            timerText.text = Std.string(Std.int(time));

            if(time < 0) {
                time = -100;
                timer.visible = false;    
                for(t in timerBits) {
                    t.visible = false;

                }
                started = false;

                board.settle();

                topText.tween({alpha:1},1);

                topText.text = 'Well Done! 
Final Rating: ';
                topText2.tween({alpha:1},1);
                topText2.text = topText.text;

                var t = 1.0;
                for(m in 1...20) {
                    t += 2/(2*(21-m));
                    var rating = Random.fromArray(authors);
                    new FlxTimer().start(t,function(_) {
                        topText.text = 'Well Done! 
Final Rating: $rating / $author';
                        topText2.text = topText.text;
                        SwapBoard.knock();
                    });
                }

                t+=2;
                new FlxTimer().start(t,function(_){
                    var again = new AgainBtn();
                    add(again);
                    again.alpha = 0.001;
                    again.tween({alpha:1},1);

                    anotherBtn.tween({alpha:1},1);
                    anotherBtn.visible=true;

                    again.x = 10;
                    again.y = 10;
                    /*
                    var share = new ShareBtn();
                    add(share);
                    share.alpha = 0.001;
                    share.tween({alpha:1},1);
                    share.x = FlxG.width-share.bg.width-10;
                    share.y = 10;
                    */
                });


            }

            timer.scale.x = time/fullTime*FlxG.width;

        }
    }


}
class AgainBtn extends FlxSpriteGroup {
    public var bg:FlxSprite;
    var label:FlxText;
    var pressed:Bool = false;
    public function new() {
        super();
        bg = new FlxSprite(0,0);
        bg.makeGraphic(Std.int(FlxG.height*0.1),Std.int(FlxG.height*0.1),0xff000000);
        bg.drawRect(1,1,bg.width-3,bg.height-3,0xffffcc66,{color:0xff804003,thickness:2,pixelHinting:true});
        add(bg);
        label = new FlxText(0,0,bg.width,"<");
        label.setFormat("assets/ChopinScript.otf", Std.int(FlxG.height*0.08), 0xff804003, CENTER);
        var label2 = new FlxText(1,1,bg.width,"<");
        label2.setFormat("assets/ChopinScript.otf", Std.int(FlxG.height*0.08),
                0xff402001, CENTER);
        add(label2);
        add(label);
    }

    override public function update(d) {
        super.update(d);

        if(pressed) return;
        if(bg.alpha > 0.5 && FlxG.mouse.justReleased) {
            if(FlxG.mouse.x > bg.x && FlxG.mouse.x < bg.x+bg.width
                    && FlxG.mouse.y > bg.y && FlxG.mouse.y < bg.y+bg.height) {
                FlxG.state.remove(PlayState.fader,true);
                FlxG.state.add(PlayState.fader);

                new FlxTimer().start(0.2,function(t) {
                    FlxG.sound.play("assets/sounds/strum.ogg");
                });
                new FlxTimer().start(0.4,function(t) {
                    PlayState.fader.tween({alpha:1},1,{onComplete:function(t) {
                        FlxTween.globalManager.clear();
                        FlxG.resetGame();
                    }});
                });
                pressed = true;
            }
        }
    }
}

class AnotherBtn extends FlxSpriteGroup {
    public var bg:FlxSprite;
    var label:FlxText;
    var pressed:Bool = false;
    public function new() {
        super();
        bg = new FlxSprite(0,0);
        bg.makeGraphic(Std.int(FlxG.width*0.18),Std.int(FlxG.height*0.08),0xff000000);
        bg.drawRect(1,1,bg.width-3,bg.height-3,0xffffcc66,{color:0xff804003,thickness:2,pixelHinting:true});
        add(bg);
        label = new FlxText(2,6,bg.width,"Another?");
        label.setFormat("assets/bop.ttf", Std.int(FlxG.height*0.05), 0xff804003, CENTER);
        var label2 = new FlxText(3,7,bg.width,"Another?");
        label2.setFormat("assets/bop.ttf", Std.int(FlxG.height*0.05),
                0xff402001, CENTER);
        add(label2);
    }

    override public function update(d) {
        super.update(d);

        if(pressed) return;
        if(bg.alpha > 0.5 && FlxG.mouse.justReleased) {
            if(FlxG.mouse.x > bg.x && FlxG.mouse.x < bg.x+bg.width
                    && FlxG.mouse.y > bg.y && FlxG.mouse.y < bg.y+bg.height) {
                FlxG.state.remove(PlayState.fader,true);
                FlxG.state.add(PlayState.fader);

                new FlxTimer().start(0.2,function(t) {
                    FlxG.sound.play("assets/sounds/strum.ogg");
                });
                new FlxTimer().start(0.6,function(t) {
                    PlayState.fader.tween({alpha:1},1,{onComplete:function(t) {
                        FlxTween.globalManager.clear();
                        FlxG.resetState();
                    }});
                });
                pressed = true;
            }
        }
    }
}
