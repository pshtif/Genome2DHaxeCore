package com.genome2d.proto;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.ui.element.GUIElement;
import Reflect;
import com.genome2d.debug.GDebug;
import haxe.rtti.Meta;

//@:access(com.genome2d.protorototypable)
class GPrototypeFactory {
    static private var g2d_helper:GPrototypeHelper;
    static private var g2d_lookupsInitialized:Bool = false;
    static private var g2d_lookups:Map<String,Class<IGPrototypable>>;

    static public function initializePrototypes():Void {
        if (g2d_lookups != null) return;
        g2d_lookups = new Map<String,Class<IGPrototypable>>();

        var fields:Dynamic = Meta.getType(IGPrototypable);
        for (i in Reflect.fields(fields)) {
            var className:String = Reflect.field(fields,i)[0];
            var cls:Class<IGPrototypable> = cast Type.resolveClass(className);
            if (cls != null) g2d_lookups.set(i, cls);
        }
    }

    static public function getPrototypeClass(p_prototypeName:String):Class<IGPrototypable> {
        return g2d_lookups[p_prototypeName];
    }

    static public function createPrototype(p_prototype:Dynamic):IGPrototypable {
        var prototypeXml:Xml;
        if (Std.is(p_prototype,Xml)) {
            prototypeXml = p_prototype;
        } else {
            prototypeXml = Xml.parse(p_prototype).firstElement();
        }
        var prototypeName:String = prototypeXml.get("class");
        var prototypeClass:Class<IGPrototypable> = g2d_lookups[prototypeName];
        if (prototypeClass == null) {
            GDebug.error("Non existing prototype class "+prototypeName);
        }

        var proto:IGPrototypable = Type.createInstance(prototypeClass,[]);
        if (proto == null) GDebug.error("Invalid prototype class "+prototypeName);

        proto.bindPrototype(prototypeXml);

        return proto;
    }

    static public function createEmptyPrototype(p_prototypeName:String):IGPrototypable {
        var prototypeClass:Class<IGPrototypable> = g2d_lookups[p_prototypeName];
        if (prototypeClass == null) {
            GDebug.error("Non existing prototype class "+p_prototypeName);
        }

        var proto:IGPrototypable = Type.createInstance(prototypeClass,[]);
        if (proto == null) GDebug.error("Invalid prototype class "+p_prototypeName);

        return proto;
    }

    static public function g2d_getPrototype(p_instance:IGPrototypable, p_prototypeXml:Xml, p_prototypeName:String, p_propertyNames:Array<String>, p_propertyTypes:Array<String>):Xml {
        if (p_prototypeXml == null) p_prototypeXml = Xml.createElement("prototype");
		
		p_prototypeXml.set("class", p_prototypeName);

        if (p_propertyNames != null) {
            for (i in 0...p_propertyNames.length) {
                var name:String = p_propertyNames[i];
                if (p_propertyTypes[i] == "IGPrototypable") {
                    var xml:Xml = Xml.createElement(name);
                    var property:com.genome2d.proto.IGPrototypable = cast Reflect.getProperty(p_instance, name);
                    if (property != null) {
                        xml.addChild(property.getPrototype());
                        p_prototypeXml.addChild(xml);
                    }
                } else {
                    p_prototypeXml.set(name,Std.string(Reflect.getProperty(p_instance, name)));
                }
            }
        }

        return p_prototypeXml;
    }

    static public function g2d_bindPrototype(p_instance:IGPrototypable, p_prototype:Xml, p_propertyNames:Array<String>, p_propertyTypes:Array<String>):Void {
        if (p_prototype == null) GDebug.error("Null prototype");

        for (i in 0...p_propertyNames.length) {
            var name:String = p_propertyNames[i];
            var type:String = p_propertyTypes[i];
            var realValue:Dynamic = null;

            if (type != "IGPrototypable" && p_prototype.exists(name)) {
                var value:String = p_prototype.get(name);
                switch (type) {
                    case "Bool":
                        realValue = (value != "false" && value != "0");
                    case "Int":
                        realValue = Std.parseInt(value);
                    case "Float":
                        realValue = Std.parseFloat(value);
                    case "String":
                        realValue = value;
                    default:
                }
            } else {
                var it:Iterator<Xml> = p_prototype.elementsNamed(name);
                if (it.hasNext()) realValue = com.genome2d.proto.GPrototypeFactory.createPrototype(it.next().firstElement());
            }

            if (realValue != null) {
                try {
                    Reflect.setProperty(p_instance, name, realValue);
                } catch (e:Dynamic) {
                }
            }

        }
        /*
        var elements:Iterator<Xml> = p_prototypeXml.elements();
        while (elements.hasNext()) {
            var element:Xml = elements.next();
            var type:String = PROTOTYPE_TYPES[PROTOTYPE_PROPERTIES_FINAL.indexOf(element.nodeName)];
            if (type == "IGPrototypable" && element.firstChild() != null) {
                var proto:com.genome2d.protorototypable = com.genome2d.proto.GPrototypeFactory.createPrototype(element.firstElement());
                try {
                    Reflect.setProperty(this, element.nodeName, proto);
                } catch (e:Dynamic) {
                }
            }
        }
        /**/
    }
}
