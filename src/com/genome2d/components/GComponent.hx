/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components;

import com.genome2d.debug.GDebug;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.node.GNode;
import com.genome2d.input.GMouseInput;

/**
    Component super class all components need to extend it
**/
@:allow(com.genome2d.node.GNode)
class GComponent implements IGPrototypable
{
	private var g2d_active:Bool = true;

    /**
	    Abstract reference to user defined data, if you want keep some custom data binded to component instance use it.
	**/
    private var g2d_userData:Map<String, Dynamic>;
    #if swc @:extern #end
    public var userData(get, never):Map<String, Dynamic>;
    #if swc @:getter(userData) #end
    inline private function get_userData():Map<String, Dynamic> {
        if (g2d_userData == null) g2d_userData = new Map<String,Dynamic>();
        return g2d_userData;
    }

	public function isActive():Bool {
		return g2d_active;
	}
	public function setActive(p_value:Bool):Void {
		g2d_active = p_value;
	}

	private var g2d_node:GNode;
    /**
        Component's node reference
     **/
	#if swc @:extern #end
	public var node(get, never):GNode;
	#if swc @:getter(node) #end
	inline private function get_node():GNode {
		return g2d_node;
	}

	public function new() {
	}
	
	/****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/
	/*
	public function getPrototype(p_xml:Xml = null):Xml {
		if (p_xml == null) p_xml = Xml.createElement("components");

		p_xml.set("class", Type.getClassName(Type.getClass(this)));
		
		var propertiesXml:Xml = Xml.createElement("properties");

        var properties:Array<String> = PROTOTYPE_PROPERTY_NAMES;

        if (properties != null) {
            for (i in 0...properties.length) {
                var property:Array<String> = properties[i].split("|");
                g2d_addPrototypeProperty(property[0], property.length>1?property[1]:"", propertiesXml);
            }
        }
		
		p_xml.addChild(propertiesXml);
		
		return p_xml;
	}
	
	private function g2d_addPrototypeProperty(p_name:String, p_type:String, p_parentXml:Xml = null):Void {
		// Discard complex types
		var propertyXml:Xml = Xml.createElement("property");

        propertyXml.set("name", p_name);
        propertyXml.set("type", p_type);

        if (p_type != "Int" && p_type != "Bool" && p_type != "Float" && p_type != "String") {
            propertyXml.set("value", "xml");
            propertyXml.addChild(cast (Reflect.getProperty(this, p_name),IGPrototypable).getPrototype());
        } else {
            propertyXml.set("value", Std.string(Reflect.getProperty(this, p_name)));
        }

		p_parentXml.addChild(propertyXml);
	}

	/**
        Abstract method called after components is initialized on the node
    **/
    public function init():Void {
    }

    public function dispose():Void {

    }

    /**

    **/
	public function bindPrototype(p_prototypeXml:Xml):Void {
		var propertiesXml:Xml = p_prototypeXml.firstElement();
		
		var it:Iterator<Xml> = propertiesXml.elements();
		while (it.hasNext()) {
			g2d_bindPrototypeProperty(it.next());
		}
	}
	
	private function g2d_bindPrototypeProperty(p_propertyXml:Xml):Void {
		var value:Dynamic = null;
		var type:Array<String> = p_propertyXml.get("type").split(":");
		
		switch (type[0]) {
			case "Bool":
				value = (p_propertyXml.get("value") == "false") ? false : true;
			case "Int":
				value = Std.parseInt(p_propertyXml.get("value"));
			case "Float":
				value = Std.parseFloat(p_propertyXml.get("value"));
            case "String":
                value = p_propertyXml.get("value");
            case _:
                var property:String = p_propertyXml.get("value");
                if (value != "null") {
                    var c:Class<Dynamic> = cast Type.resolveClass(type[0]);
                    value = Type.createInstance(c,[]);
                    value.bindPrototype(Xml.parse(property));
                }
		}

		try {
			Reflect.setProperty(this, p_propertyXml.get("name"), value);
		} catch (e:Dynamic) {
			//GDebug.warning("bindPrototypeProperty error", e, p_propertyXml.get("name"), value);
		}
	}
	
	/**
	    Base dispose method, if there is a disposing you need to do in your extending components you should override it and always call super.dispose() its used when a node using this components is being disposed
	**/
	private function g2d_dispose():Void {
        dispose();

		g2d_active = false;
		
		g2d_node = null;
	}
}