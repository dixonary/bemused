package;

import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;

class Surround extends FlxSprite {

    public function new(W:Int,H:Int,Thickness:Int,Color:Int) {
        super();

        makeGraphic(W+Thickness*2, H+Thickness*2,(Color&0xffffff));

        drawRect(0,0,W+Thickness*2, Thickness,Color,{color:0x00ffffff,thickness:0});
        drawRect(0,H+Thickness,W+Thickness*2, Thickness,Color,{color:0x00ffffff,thickness:0});
        drawRect(0,0,Thickness, H+Thickness*2,Color,{color:0x00ffffff,thickness:0});
        drawRect(W+Thickness,0,Thickness,
                H+Thickness*2,Color,{color:0x00ffffff,thickness:0});

    }

}
