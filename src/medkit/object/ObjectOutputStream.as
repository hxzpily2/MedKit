/**
 * User: booster
 * Date: 19/05/14
 * Time: 9:44
 */
package medkit.object {
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

public class ObjectOutputStream {
    private var _jsonData:Object                = { serializedObjects : [], globalKeys : {} };
    private var _savedObjectIndexes:Dictionary  = new Dictionary();
    private var _context:Object                 = null;

    public function get jsonData():Object { return _jsonData; }

    public function writeBoolean(value:Boolean, key:String):void {
        writeAny(value, key);
    }

    public function writeInt(value:int, key:String):void {
        writeAny(value, key);
    }

    public function writeUnsignedInt(value:uint, key:String):void {
        writeAny(value, key);
    }

    public function writeNumber(value:Number, key:String):void {
        writeAny(value, key);
    }

    public function writeString(value:String, key:String):void {
        writeAny(value, key);
    }

    public function writeObject(value:Object, key:String):void {
        writeAny(value, key);
    }

    public function writeAny(value:*, key:String):void {
        var obj:Object;

        if(value == null) {
            obj = { thisIsANullObject : true };

            if(_context == null)    _jsonData.globalKeys[key] = obj;
            else                    _context.members[key] = obj;
        }
        else if(typeof(value) != "object") {
            obj = value;

            if(_context == null)    _jsonData.globalKeys[key] = obj;
            else                    _context.members[key] = obj;
        }
        else if(_savedObjectIndexes[value] == null) {
            obj = { className : getQualifiedClassName(value), members : {}};

            _savedObjectIndexes[value] = _jsonData.serializedObjects.length;
            _jsonData.serializedObjects[_jsonData.serializedObjects.length] = obj;

            if(_context == null)    _jsonData.globalKeys[key] = { objectIndex : _jsonData.serializedObjects.length - 1 };
            else                    _context.members[key] = { objectIndex : _jsonData.serializedObjects.length - 1 };

            var oldContext:Object = _context;
            _context              = obj;

            if(value is Array) {
                var arr:Array = value as Array;

                var count:int = arr.length;
                for(var i:int = 0; i < count; ++i) {
                    var arrElem:*       = arr[i];
                    var arrKey:String   = String(i);

                    if(typeof(arrElem) != "object") {
                        _context.members[arrKey] = arrElem;
                        continue;
                    }

                    writeAny(arrElem, arrKey);
                }
            }
            else if(value is Dictionary) {
                var dict:Dictionary = value as Dictionary;

                for(var dictKey:Object in dict) {
                    if(dictKey is String == false)
                        throw new TypeError("ale keys of serialized Dictionary has to be Strings");

                    var dictElem:* = dict[dictKey];

                    if(typeof(dictElem) != "object") {
                        _context.members[dictKey] = dictElem;
                        continue;
                    }

                    writeAny(dictElem, dictKey as String);
                }
            }
            else if(ObjectUtil.getClass(value) == obj) {
                var o:Object = value as Object;

                for(var oKey:String in o) {
                    var oElem:* = o[oKey];

                    if(typeof(oElem) != "object") {
                        _context.members[oKey] = oElem;
                        continue;
                    }

                    writeAny(oElem, oKey);
                }
            }
            else if(value is Serializable) {
                var serializable:Serializable = value as Serializable;

                serializable.writeObject(this);
            }
            else {
                throw new TypeError("value '" + value + "' for key '" + key + "' is not an Array or Dictionary and does not implement 'Serializable'");
            }

            _context = oldContext;
        }
        else {
            var index:int = _savedObjectIndexes[value];

            if(_context != null)
                _context.members[key] = { objectIndex : index };
        }
    }
}
}
