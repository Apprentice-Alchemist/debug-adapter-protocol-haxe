import haxe.macro.Expr.TypeDefinition;
import haxe.DynamicAccess;

using Reflect;

enum abstract JType(String) {
	var JNull = "null";
	var JBool = "boolean";
	var JObject = "object";
	var JArray = "array";
	var JNumber = "number";
	var JString = "string";
	var JInteger = "integer";
}

typedef JSchema = {
	var title:String;
	var description:String;
	var type:JType;

	var definitions:haxe.DynamicAccess<Dynamic>;
}

typedef JDefinition = {
	var ?$ref:String;

	var type:String;
	var description:String;
	var properties:DynamicAccess<{var type:JType;}>;
}

function main() {
	return trace("Nope");
	final protocol:JSchema = haxe.Json.parse(sys.io.File.getContent("debugAdapterProtocol.json"));
	final type_definitions:Array<TypeDefinition> = [];
	for (def in protocol.definitions) {
		if (def.allOf != (null : Null<Array<String>>)) {
			var parents = [];
			for (type in def.allOf) {
				if (type.hasField("$ref")) {
					parents.push((type.field("$ref") : String).split("/").pop());
				} else {}
			}
		}
	}
}
