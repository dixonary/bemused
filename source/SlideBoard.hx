package;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;

class SlideBoard extends FlxSpriteGroup
{
    public var pieces:Array<Piece> = [];
    public var tilesW:Int;
    public var tilesH:Int;
    public var Width:Int;
    public var Height:Int;

    public var rowLock:Null<Int> = null;
    public var colLock:Null<Int> = null;
    public var dirLock:Null<Dir> = null;
    public var move(default,set):Int = 0; 

    public static var instance:SlideBoard;

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
    }

    public function set_move(M:Int):Int {
        switch(dirLock) {
        case null:
        case HORIZONTAL:
            var movers = pieces.filter(function(p) return p.pY == rowLock);
            for(m in movers) {
                var nX = m.homeX;
                nX -= x;
                nX += M;
                while(nX < 0) nX += Width;
                while(nX >= Width) nX -= Width;
                nX += x;
                m.x = nX;
            }

        case VERTICAL:
            var movers = pieces.filter(function(p) return p.pX == colLock);
            for(m in movers) {
                var nY = m.homeY;
                nY -= y;
                nY += M;
                while(nY < 0) nY += Height;
                while(nY >= Height) nY -= Height;
                nY += y;
                m.y = nY;
            }
        }
        return move=M;
    }

    public function settle() {
        switch(dirLock) {
        case null:
        case HORIZONTAL:
            var movers = pieces.filter(function(p) return p.pY == rowLock);
            for(m in movers) {
                var numMoved = Std.int(Math.round(move/Std.int(Width/tilesW)));
                m.pX += numMoved;
                while(m.pX < 0) m.pX += tilesW;
                while(m.pX >= tilesW) m.pX -= tilesW;

                m.x = m.homeX = Std.int(m.pX*Width/tilesW) + x;
            }
        case VERTICAL:
            var movers = pieces.filter(function(p) return p.pX == colLock);
            for(m in movers) {
                var numMoved = Std.int(Math.round(move/Std.int(Width/tilesH)));
                m.pY += numMoved;
                while(m.pY < 0) m.pY += tilesH;
                while(m.pY >= tilesH) m.pY -= tilesH;

                m.y = m.homeY = Std.int(m.pY*Height/tilesH) + y;
            }
        }
    }

}

enum Dir {
    HORIZONTAL;
    VERTICAL;
}

class Piece extends FlxSprite {

    public var pX:Int;
    public var pY:Int;
    public var homeX:Float;
    public var homeY:Float;

    var pickedAt:FlxPoint;

    public function new(X,Y,W,H) {
        super();
        pX = X;
        pY = Y;
        makeGraphic(W,H,0xffffffff);
        color = Std.int(Math.random()*0xffffff);
    }

    override public function update(d) {
        super.update(d);

        if(pickedAt != null) {
            /*
            trace("picked");
            trace("SlideBoard.instance.dirLock "+SlideBoard.instance.dirLock);
            trace("SlideBoard.instance.colLock "+SlideBoard.instance.colLock);
            trace("SlideBoard.instance.rowLock "+SlideBoard.instance.rowLock);
            */
            if(FlxG.mouse.justReleased) 
                release();
            
            // currently being moved
            else {
                var nsp = FlxG.mouse.getScreenPosition();

                if(SlideBoard.instance.dirLock != null) {
                    SlideBoard.instance.move = 
                        (SlideBoard.instance.dirLock == HORIZONTAL)
                            ? Std.int(nsp.x - pickedAt.x)
                            : Std.int(nsp.y - pickedAt.y);            
                }
                else if(!nsp.equals(pickedAt)) {
                    var ratio = Math.abs(nsp.x-pickedAt.x)
                              / Math.abs(nsp.y-pickedAt.y);
                    var dist = (nsp.x-pickedAt.x)+(nsp.y-pickedAt.y);
                    if(Math.abs(dist) > 8) {
                        if(ratio > 1) {
                            SlideBoard.instance.dirLock = HORIZONTAL;
                            SlideBoard.instance.rowLock = pY;
                        }
                        if(ratio < 1) {
                            SlideBoard.instance.dirLock = VERTICAL; 
                            SlideBoard.instance.colLock = pX;
                        }
                    }
                } 
            }
        }
        else if(FlxG.mouse.justPressed) {
            if(pixelsOverlapPoint(FlxG.mouse.getScreenPosition())) 
                press();
            
        }
    }

    function press() {
        pickedAt = new FlxPoint();
        pickedAt.x = FlxG.mouse.getScreenPosition().x;
        pickedAt.y = FlxG.mouse.getScreenPosition().y;
    }
    function release() {
        pickedAt = null;
        SlideBoard.instance.settle();
        SlideBoard.instance.dirLock = null;
        SlideBoard.instance.rowLock = null;
        SlideBoard.instance.colLock = null;
        //trace("UP");
    }


}
