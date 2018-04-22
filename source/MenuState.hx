package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import textbox.Textbox;
import textbox.Settings;
using flixel.tweens.FlxTween;

class MenuState extends FlxState {

    public static var music:FlxSound;
    public static var fader:FlxSprite;

    override public function create() {
        super.create();

        var bg = new FlxSprite(0,0,"assets/images/wood.jpg");
        bg.alpha = 0.2;
        bg.scale.x = FlxG.width/bg.width;
        bg.scale.y = FlxG.height/bg.height;
        bg.updateHitbox();
        add(bg);

        FlxG.cameras.bgColor = 0xff806837;
        var board = new SwapBoard(Std.int(FlxG.width*0.9),
                Std.int(FlxG.width*0.9*5/37),37,5);

        board.y = FlxG.height*0.3;
        board.x = FlxG.width*0.05;

        var surr = new Surround(Std.int(FlxG.width*0.9),
                Std.int(FlxG.width*0.9*5/37), 5, 0xff402001);
        add(surr);
        surr.x = board.x-5;
        surr.y = board.y-5;
        add(board);


        var img = new FlxSprite(0,0,"assets/images/bemused2.png");
        var cnt=0;
        for(i in 0...37) {
            for(j in 0...5) {
                board.pieces[cnt++].color = img.pixels.getPixel(i,j);
            }
        }

        var swaps = [
             {p1:{x:9,y:4},p2:{x:10,y:2}},
             {p1:{x:8,y:4},p2:{x:8,y:2}},
             {p1:{x:8,y:0},p2:{x:8,y:3}},
             {p1:{x:10,y:0},p2:{x:10,y:1}},
             {p1:{x:13,y:2},p2:{x:14,y:1}},
             {p1:{x:14,y:4},p2:{x:15,y:0}},
             {p1:{x:17,y:4},p2:{x:18,y:2}},
             {p1:{x:13,y:4},p2:{x:18,y:1}},
             {p1:{x:9,y:0},p2:{x:18,y:0}},
             {p1:{x:22,y:3},p2:{x:24,y:3}},
             {p1:{x:28,y:4},p2:{x:28,y:3}},
             {p1:{x:27,y:4},p2:{x:27,y:3}},
             {p1:{x:26,y:4},p2:{x:28,y:2}},
             {p1:{x:26,y:3},p2:{x:27,y:2}},
             {p1:{x:26,y:0},p2:{x:27,y:1}}
        ];

        var t:Float = 2;
        var t_step = 0.15;
        while(swaps.length > 0) {
            var rand = Std.int(Math.random()*swaps.length);
            var s = swaps.splice(rand,1)[0];

            t += t_step;
            new FlxTimer().start(t, function(t) {
                board.swap(s.p1.x, s.p1.y, s.p2.x, s.p2.y);
            });
        }

        var subtitle = new FlxText(FlxG.width*0.05,FlxG.height*0.6);
        subtitle.text = ("The Block-Switching Paint-Em-Up.");
        subtitle.setFormat("assets/ChopinScript.otf", 40, 0xff804003, LEFT);
        var subtitle2 = new FlxText(FlxG.width*0.05+1,FlxG.height*0.6+1);
        subtitle2.text = ("The Block-Switching Paint-Em-Up.");
        subtitle2.setFormat("assets/ChopinScript.otf", 40, 0xff402001, LEFT);
        add(subtitle2);
        add(subtitle);
        subtitle2.alpha = 0.001;
        subtitle.alpha = 0.001;

        t += t_step*5;
        new FlxTimer().start(t, function(t) {
            subtitle.tween({alpha:1},2);
            subtitle2.tween({alpha:1},2);
        });

        var btn = new PlayBtn();
        btn.x = FlxG.width/2-btn.bg.width/2;
        btn.y = FlxG.height*0.9-btn.bg.height;

        add(btn);
        btn.alpha = 0.01;

        t += 4;
        new FlxTimer().start(t, function(t) {
            btn.tween({alpha:1},0.5);
        });

        music = new FlxSound();
        music.loadEmbedded("assets/music/nachtmusik.ogg");
        music.looped = true;
        music.play();

        fader = new FlxSprite();
        fader.makeGraphic(1,1,0xffffffff);
        fader.alpha = 0;
        fader.scale.x = FlxG.width;
        fader.scale.y = FlxG.height;
        fader.updateHitbox();
        add(fader);

        FlxG.mouse.load("assets/images/paintbrush.png");

    }

}

class PlayBtn extends FlxSpriteGroup {
    public var bg:FlxSprite;
    var label:FlxText;
    var pressed:Bool = false;
    public function new() {
        super();
        bg = new FlxSprite(0,0);
        bg.makeGraphic(Std.int(FlxG.width*0.3),Std.int(FlxG.height*0.1),0xff000000);
        bg.drawRect(1,1,bg.width-3,bg.height-3,0xffffcc66,{color:0xff804003,thickness:2,pixelHinting:true});
        add(bg);
        label = new FlxText(0,0,bg.width,"Play");
        label.setFormat("assets/ChopinScript.otf", Std.int(FlxG.height*0.08), 0xff804003, CENTER);
        var label2 = new FlxText(1,1,bg.width,"Play");
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

                MenuState.music.tween({volume:0}, 1.4);
                new FlxTimer().start(0.2,function(t) {
                    FlxG.sound.play("assets/sounds/strum.ogg");
                });
                new FlxTimer().start(0.4,function(t) {
                    MenuState.fader.tween({alpha:1},1,{onComplete:function(t) {
                        FlxG.switchState(new PlayState());
                    }});
                });
                pressed = true;
            }
        }
    }
}


