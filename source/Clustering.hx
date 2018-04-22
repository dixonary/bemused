package;
import flixel.util.FlxColor;

class Clustering {

    static public function ColorQuantize (Colors:Array<Int>, iters:Int =
            4):Map<Int,Int> {

        trace(iters);

        //Color Quantization = repeated bisection.
        var cols = Colors.map(function(c) { return new FlxColor(c); }); 
        
        if(iters == 0) {
            
            var sums = {h:0.0         ,s:0.0         ,b:0.0         };
            for(c in cols) {
                sums.h += c.hue; sums.s += c.saturation; sums.b += c.brightness;
            }
            sums.h = sums.h/cols.length; 
            sums.s = sums.s/cols.length; 
            sums.b = sums.b/cols.length; 
            var avgColor = new
                FlxColor(0xff000000);
            avgColor.setHSB(sums.h,sums.s,sums.b,1);
            trace(new FlxColor(avgColor).toHexString());

            var m:Map<Int,Int> = new Map();
            for(c in cols) {
                m[c] = avgColor;
            }
            return m;
        }
        else {
            // 1: Find the channel with the greatest range.
            var mins = {r:0xffffffff,g:0xffffffff,b:0xffffffff};
            var maxs = {r:0         ,g:0         ,b:0         };
            for(c in cols) {
                if(c.red   < mins.r) mins.r = c.red;
                if(c.green < mins.g) mins.g = c.green;
                if(c.blue  < mins.b) mins.b = c.blue;
                if(c.red   > maxs.r) maxs.r = c.red;
                if(c.green > maxs.g) maxs.g = c.green;
                if(c.blue  > maxs.b) maxs.b = c.blue;
            }
            var diffs = {r:maxs.r-mins.r,g:maxs.g-mins.g,b:maxs.b-mins.b};
            var colsL;
            var colsR;
            
            if(diffs.r > diffs.g && diffs.r > diffs.b) {
                // red biggest range
                cols.sort(function(a,b) { return 
                    a.red < b.red?-1
                   :a.red > b.red?1
                   :0; });
            }
            else if(diffs.g > diffs.r && diffs.g > diffs.b) {
                // green biggest range
                cols.sort(function(a,b) { return 
                    a.green < b.green?-1
                   :a.green > b.green?1
                   :0; });
            }
            else {
                // blue biggest range
                cols.sort(function(a,b) { return 
                    a.blue < b.blue?-1
                   :a.blue > b.blue?1
                   :0; });
            }

            colsL = cols.slice(0,Std.int(cols.length/2)); 
            colsR = cols.slice(Std.int(cols.length/2));
            trace(colsL + "," + colsR);

            var colsLM = ColorQuantize(colsL, iters-1);
            var colsRM = ColorQuantize(colsR, iters-1);

            //union colsL and colsR (into colsL
            for(c in colsRM.keys()) {
                if(colsLM[c] == null) {
                    colsLM[c] = colsRM[c];
                }
            }

            return colsLM;
        }

    }

}
