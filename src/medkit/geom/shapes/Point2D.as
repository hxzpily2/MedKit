/**
 * User: booster
 * Date: 14/05/14
 * Time: 9:38
 */
package medkit.geom.shapes {
import flash.geom.Point;

import medkit.collection.spatial.Spatial;
import medkit.object.Hashable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.Serializable;

public class Point2D extends Point implements Hashable, Spatial, Serializable {
    public function Point2D(x:Number = 0, y:Number = 0) {
        super(x, y);
    }

    public function distance(point:Point):Number {
        var dy:Number = point.y - y;
        var dx:Number = point.x - x;

        return Math.sqrt(dx * dx + dy * dy);
    }

    public function distanceSq(point:Point):Number {
        var dy:Number = point.y - y;
        var dx:Number = point.x - x;

        return dx * dx + dy * dy;
    }

    public function setLocation(point:Point2D):void {
        x = point.x;
        y = point.y;
    }

    public function project(angle:Number, distance:Number):Point2D {
        return new Point2D(
            (x + Math.sin(angle) * distance),
            (y - Math.cos(angle) * distance)    // minus when Y-Axis is going down, plus when it's going up
        );
    }

    public function hashCode():int {
        return ((y << 16) | x);
    }

    override public function clone():Point {
        return new Point2D(x, y);
    }

    public function readObject(input:ObjectInputStream):void {
        x = input.readNumber("x");
        y = input.readNumber("y");
    }

    public function writeObject(output:ObjectOutputStream):void {
        output.writeNumber(x, "x");
        output.writeNumber(y, "y");
    }

    public function get indexCount():int { return 2; }
    public function minValue(index:int):Number { return index == 0 ? x : y; }
    public function maxValue(index:int):Number { return index == 0 ? x : y; }
}
}
