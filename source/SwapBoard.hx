package;

import flixel.group.FlxSpriteGroup;
using flixel.util.FlxSpriteUtil;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.FlxG;
using flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.system.FlxSound;

class SwapBoard extends FlxSpriteGroup
{
    public var pieces:Array<Piece> = [];
    public var tilesW:Int;
    public var tilesH:Int;
    public var Width:Int;
    public var Height:Int;

    public var selected:Piece;
    public var state:State = SEL1;

    public static var instance:SwapBoard;

    public static var knocks:Array<FlxSound>;

    public function new(Width:Int,Height:Int,Cols:Int,Rows:Int) {
        super();
        tilesW = Cols;
        tilesH = Rows;
        this.Width = Width;
        this.Height = Height;
        instance = this;

        for(i in 0...Cols) {
            for(j in 0...Rows) {
                var p = new Piece(i,j,Std.int(Width/Cols), Std.int(Height/Rows));
                add(p);
                p.homeX = p.x = Std.int(i*Width/Cols);
                p.homeY = p.y = Std.int(j*Height/Rows);
                pieces.push(p);
            }
        }

        if(knocks == null) {
            knocks = [ for(i in 1...3)
                new FlxSound().loadEmbedded('assets/sounds/knock$i.ogg')];
        }
    }

    public function settle() {
        switch(state) {
            case SEL1: return;
            case SEL2: selected.scale.tween({x:1,y:1},0.1);
            case SWAPPING:return;
        }
    }

    public static function knock() {
        if(knocks == null) return;

        var k = knocks[Math.floor(Math.random()*knocks.length)];
        k.volume = 0.2;
        k.play();
    }
    
    override public function update(d) {
        super.update(d);
        if(state == SEL1) {
            selected = null;
        }
        if(Piece.clicked>0) Piece.clicked--;
    }

    public function swap(X1,Y1,X2,Y2) {
        if(state == SEL1) {
            pieces[X1*tilesH+Y1].press(false);
            pieces[X2*tilesH+Y2].press(false);
            state = SEL1;
        }
    }

}

enum State{
    SEL1;
    SEL2;
    SWAPPING;
}

class Piece extends FlxSprite {

    public var pX:Int;
    public var pY:Int;
    public var homeX:Float;
    public var homeY:Float;

    public static var clicked:Int = 0;

    public static var BorderCorner:Int = 8;

    var pickedAt:FlxPoint;

    public function new(X,Y,W,H) {
        super();
        pX = X;
        pY = Y;
        makeGraphic(W,H,0x00ffffff);

        drawRoundRect(1,1,W-1,H-1,BorderCorner,BorderCorner);

        color = Std.int(Math.random()*0xffffff);
    }

    override public function update(d) {
        super.update(d);

        if(FlxG.mouse.justPressed && clicked==0) {
            
            if(  x<FlxG.mouse.x && x+width>FlxG.mouse.x
              && y<FlxG.mouse.y && y+height>FlxG.mouse.y) {
                press();

                clicked = 3;
            }
            
        }
    }

    public function press(cancel:Bool = true) {
        var other = SwapBoard.instance.selected;

        if(PlayState.time == -100) return;

        SwapBoard.instance.remove(this,true);
        SwapBoard.instance.add(this);

        if(SwapBoard.instance.state == SEL1) {
            SwapBoard.instance.selected = this;
            if(cancel) FlxTween.globalManager.completeAll();
            scale.tween({x:1.4,y:1.4},0.3);
            SwapBoard.instance.state = SEL2;
        }
        else if(SwapBoard.instance.state == SEL2 && other == this) {
            if(cancel) FlxTween.globalManager.completeAll();
            SwapBoard.instance.state = SWAPPING;
            scale.tween({x:1,y:1},0.15,{onComplete:function(t) {
                SwapBoard.instance.state=SEL1;
                SwapBoard.knock();
            }});
        }

        else if(SwapBoard.instance.state == SEL2 && other != this) {
            if(cancel) FlxTween.globalManager.completeAll();

            scale.tween({x:1.4,y:1.4},0.1, {onComplete:function(t){

                other.tween({x:x,y:y},0.3, {onComplete:function(t) {
                    other.scale.tween({x:1,y:1},0.15, {onComplete:function(t) {
                        SwapBoard.instance.state = SEL1;
                        SwapBoard.knock();
                    }});
                }});
                tween({x:other.x, y:other.y},0.3, {onComplete:function(t) {
                    scale.tween({x:1,y:1},0.15); }});

            }});

            var thX = other.homeX;
            var thY = other.homeY;
            var tpX = other.pX;
            var tpY = other.pY;
            other.homeX = homeX;
            other.homeY = homeY;
            other.pX = pX;
            other.pY = pY;
            homeX = thX;
            homeY = thY;
            pX = tpX;
            pY = tpY;

            SwapBoard.instance.state = SWAPPING;

            if(Std.is(FlxG.state,PlayState)) {
                var state = cast(FlxG.state,PlayState);
                state.startTimer();
            }

        }
    }

}
