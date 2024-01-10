package hxd.fmt.fbx;

import hxd.fmt.fbx.Data;
import hxd.fmt.hmd.Data;

class Writer {
	var out:haxe.io.Output;
	var version:Int;

	public function new(out) {
		this.out = out;
	}

	function getTabFormat(depth:Int) {
		return '${StringTools.rpad("", '\t', depth)}';
	}

	function writeNode(n:FbxNode, depth:Int = 0) {
		out.writeString('${getTabFormat(depth)}${n.name}:');

		if (n.props != null && n.props.length > 0) {
			for (idx => p in n.props) {
				out.writeString('${idx != 0 ? ',' : ''}${(p.match(PInt(_)) || p.match(PFloat(_))) && idx != 0 ? '' : ' '}${writeProperty(p, depth)}');
			}
		}

		if (n.childs == null || n.childs.length <= 0)
			out.writeString('\n');
		else {
			out.writeString(' {\n');
			for (c in n.childs) {
				writeNode(c, depth + 1);
			}
			out.writeString('${getTabFormat(depth)}}\n');
		}
	}

	function writeProperty(p:FbxProp, depth:Int) {
		switch (p) {
			case PInt(v):
				return Std.string(v);

			case PFloat(v):
				return Std.string(v);

			case PString(v):
				return '"${v}"';

			case PIdent(i):
				return i;

			case PInts(v):
				{
					var res = '*${v.length} {\n';
					res += '${getTabFormat(depth + 1)}a: ';

					for (idx => i in v) {
						res += '${idx != 0 ? ',' : ''}${i}';
					}

					res += '\n${getTabFormat(depth)}}';
					return res;
				}

			case PFloats(v):
				{
					var res = '*${v.length} {\n';
					res += '${getTabFormat(depth + 1)}a: ';

					for (idx => i in v) {
						res += '${idx != 0 ? ',' : ''}${i}';
					}

					res += '\n${getTabFormat(depth)}}';
					return res;
				}

			default:
				return "Unsupported data";
		}
	}

	function writeHeader() {
		var fbxVersion = "7.3.0";
		out.writeString('; FBX ${fbxVersion} project file\n');
		out.writeString('; Copyright (C) 1997-2010 Autodesk Inc. and/or its licensors.\n');
		out.writeString('; All rights reserved.\n');
		out.writeString('; ----------------------------------------------------\n');
		out.writeString('\n');

		writeNode(buildHeaderNode());
	}

	function buildTimeStampNode() : FbxNode{
		var date = Date.now();
		var tsVersion : FbxNode = {name: "Version", props:[PInt(1000)], childs:null};
		var tsYear : FbxNode = {name: "Year", props:[PInt(date.getFullYear())], childs:null};
		var tsMonth : FbxNode = {name: "Month", props:[PInt(date.getMonth())], childs:null};
		var tsDay : FbxNode = {name: "Day", props:[PInt(date.getDay())], childs:null};
		var tsHour : FbxNode = {name: "Hour", props:[PInt(date.getHours())], childs:null};
		var tsMinutes : FbxNode = {name: "Minute", props:[PInt(date.getMinutes())], childs:null};
		var tsSeconds : FbxNode = {name: "Second", props:[PInt(date.getSeconds())], childs:null};
		var tsMilliseconds : FbxNode = {name: "Millisecond", props:[PInt(0)], childs:null};
		var ts : FbxNode = {name: "CreationTimeStamp", props:null, childs:[tsVersion, tsYear, tsMonth, tsDay, tsHour, tsMinutes, tsSeconds, tsMilliseconds]};
		return ts;
	}

	function buildSceneInfoMetaDataNode() : FbxNode {
		var version : FbxNode = {name:"Version", props:[PInt(100)], childs: []};
		var title : FbxNode = {name:"Title", props:[PString("")], childs: []};
		var subject : FbxNode = {name:"Subject", props:[PString("")], childs: []};
		var author : FbxNode = {name:"Author", props:[PString("")], childs: []};
		var keywords : FbxNode = {name:"Keywords", props:[PString("")], childs: []};
		var revision : FbxNode = {name:"Revision", props:[PString("")], childs: []};
		var comment : FbxNode = {name:"Comment", props:[PString("")], childs: []};

		var metadata : FbxNode = {name:"MetaData", props:null, childs: [version, title, subject, author, keywords, revision, comment]};
		return metadata;
	}

	function buildSceneInfoPropertiesNode() : FbxNode {
		var properties : FbxNode = {name:"Properties70", props: null, childs:[
			{name:"P", props:[PString("DocumentUrl"), PString("KString"), PString("Url"), PString(""), PString("C:\\")], childs:null},
			{name:"P", props:[PString("SrcDocumentUrl"), PString("KString"), PString("Url"), PString(""), PString("C:\\")], childs:null},
			{name:"P", props:[PString("Original"), PString("Compound"), PString(""), PString("")], childs:null},
			{name:"P", props:[PString("Original|ApplicationVendor"), PString("KString"), PString(""), PString(""), PString("")], childs:null},
			{name:"P", props:[PString("Original|ApplicationName"), PString("KString"), PString(""), PString(""), PString("")], childs:null},
			{name:"P", props:[PString("Original|ApplicationVersion"), PString("KString"), PString(""), PString(""), PString("")], childs:null},
			{name:"P", props:[PString("Original|DateTime_GMT"), PString("DateTime"), PString(""), PString(""), PString("01/01/1970 00:00:00.000")], childs:null},
			{name:"P", props:[PString("Original|FileName"), PString("KString"), PString(""), PString(""), PString("/foobar.fbx")], childs:null},
			{name:"P", props:[PString("LastSaved"), PString("Compound"), PString(""), PString("")], childs:null},
			{name:"P", props:[PString("LastSaved|ApplicationVendor"), PString("KString"), PString(""), PString(""), PString("")], childs:null},
			{name:"P", props:[PString("LastSaved|ApplicationVersion"), PString("KString"), PString(""), PString(""), PString("")], childs:null},
			{name:"P", props:[PString("LastSaved|DateTime_GMT"), PString("DateTime"), PString(""), PString(""), PString("01/01/1970 00:00:00.000")], childs:null},
			{name:"P", props:[PString("Original|ApplicationNativeFile"), PString("KString"), PString(""), PString(""), PString("")], childs:null},
		]};

		return properties;
	}

	function buildSceneInfoNode() : FbxNode {
		var type : FbxNode = {name : "Type", props: [PString("UserData")], childs: null};
		var version : FbxNode = {name : "Version", props: [PInt(100)], childs: null};

		var sceneInfo : FbxNode = {name: "SceneInfo", props:[PString("SceneInfo::GlobalInfo"), PString("UserData")], childs: [type, version, buildSceneInfoMetaDataNode(), buildSceneInfoPropertiesNode()]};
		return sceneInfo;
	}

	function buildHeaderNode() : FbxNode {
		var headerVersion : FbxNode = {name:"FBXHeaderVersion", props: [PInt(1003)], childs: null};
		var version : FbxNode = {name:"FBXVersion", props: [PInt(7003)], childs: null};
		var creator : FbxNode = {name:"Creator", props: [PString("")], childs: null};

		var header : FbxNode = {name:"FBXHeaderExtension", props: null, childs: [headerVersion, version, buildTimeStampNode(), creator, buildSceneInfoNode()]};
		return header;
	}

	function buildProperties() {
		var properties : FbxNode = { name:"Properties70", props: null, childs: [
			{ name: "P", props: [PString("UpAxis"), PString("int"), PString("Integer"), PString(""), PInt(2) ], childs:null },
			{ name: "P", props: [PString("UpAxisSign"), PString("int"), PString("Integer"), PString(""), PInt(1) ], childs:null },
			{ name: "P", props: [PString("FrontAxis"), PString("int"), PString("Integer"), PString(""), PInt(0) ], childs:null },
			{ name: "P", props: [PString("FrontAxisSign"), PString("int"), PString("Integer"), PString(""), PInt(-1) ], childs:null },
			{ name: "P", props: [PString("CoordAxis"), PString("int"), PString("Integer"), PString(""), PInt(1) ], childs:null },
			{ name: "P", props: [PString("CoordAxisSign"), PString("int"), PString("Integer"), PString(""), PInt(-1) ], childs:null },
			{ name: "P", props: [PString("OriginalUpAxis"), PString("int"), PString("Integer"), PString(""), PInt(-1) ], childs:null },
			{ name: "P", props: [PString("OriginalUpAxisSign"), PString("int"), PString("Integer"), PString(""), PInt(1) ], childs:null },
			{ name: "P", props: [PString("UnitScaleFactor"), PString("double"), PString("Number"), PString(""), PInt(100) ], childs:null },
			{ name: "P", props: [PString("OriginalUnitScaleFactor"), PString("double"), PString("Number"), PString(""), PInt(1) ], childs:null },
			{ name: "P", props: [PString("AmbientColor"), PString("ColorRGB"), PString("Color"), PString(""), PInt(0), PInt(0), PInt(0) ], childs:null },
			{ name: "P", props: [PString("DefaultCamera"), PString("KString"), PString(""), PString(""), PString("Producer Perspective") ], childs:null },
			{ name: "P", props: [PString("TimeMode"), PString("enum"), PString(""), PString(""), PInt(11) ], childs:null },
			{ name: "P", props: [PString("TimeSpanStart"), PString("Ktime"), PString("Time"), PString(""), PInt(0) ], childs:null },
			{ name: "P", props: [PString("TimeSpanStop"), PString("Ktime"), PString("Time"), PString(""), PInt(0) ], childs:null },
			{ name: "P", props: [PString("CustomFrameRate"), PString("double"), PString("Number"), PString(""), PInt(24) ], childs:null },
		] };
		return properties;
	}

	function buildGlobalSettings() {
		var version : FbxNode = {name:"Version", props: [PInt(1000)], childs: null};
		var properties : FbxNode = buildProperties();

		var globalSettings : FbxNode = {name:"GlobalSettings", props: null, childs: [version, properties]};
		return globalSettings;
	}

	function buildDefinitions(objects: Array<h3d.scene.Object>) {
		var defGlobalSettings : FbxNode = { name:"ObjectType", props:[PString("GlobalSettings")], childs: [
			{ name: "Count", props: [PInt(1)], childs: null }
		] };

		var meshCount = 0;

		for (o in objects)
			meshCount += o.getMeshes().length;

		var modelCount = meshCount;
		var defModel : FbxNode = { name:"ObjectType", props:[PString("Model")], childs: [
			{ name: "Count", props: [PInt(modelCount)], childs: null },
			{ name: "PropertyTemplate", props: [PString("FbxNode")], childs: [
				{ name:"Properties70", props: null, childs: [
					{ name: "P", props: [PString("QuaternionInterpolate"), PString("enum"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationOffset"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationPivot"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingOffset"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingPivot"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("TranslationActive"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("TranslationMin"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("TranslationMax"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("TranslationMinX"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("TranslationMinY"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("TranslationMinZ"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("TranslationMaxX"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("TranslationMaxY"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("TranslationMaxZ"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationOrder"), PString("enum"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationSpaceForLimitOnly"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationStiffnessX"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationStiffnessY"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationStiffnessZ"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("AxisLen"), PString("double"), PString("Number"), PString(""), PInt(10)], childs:null },
					{ name: "P", props: [PString("PreRotation"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("PostRotation"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationActive"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationMin"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationMax"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationMinX"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationMinY"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationMinZ"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationMaxX"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationMaxY"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("RotationMaxZ"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("InheritType"), PString("enum"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingActive"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingMin"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingMax"), PString("Vector3D"), PString("Vector"), PString(""), PInt(1), PInt(1), PInt(1)], childs:null },
					{ name: "P", props: [PString("ScalingMinX"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingMinY"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingMinZ"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingMaxX"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingMaxY"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("ScalingMaxZ"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("GeometricTranslation"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("GeometricRotation"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("GeometricScaling"), PString("Vector3D"), PString("Vector"), PString(""), PInt(1), PInt(1), PInt(1)], childs:null },
					{ name: "P", props: [PString("MinDampRangeX"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MinDampRangeY"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MinDampRangeZ"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MaxDampRangeX"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MaxDampRangeY"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MaxDampRangeZ"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MinDampStrengthX"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MinDampStrengthY"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MinDampStrengthZ"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MaxDampStrengthX"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MaxDampStrengthY"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("MaxDampStrengthZ"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("PreferedAngleX"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("PreferedAngleY"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("PreferedAngleZ"), PString("double"), PString("Number"), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("LookAtProperty"), PString("object"), PString(""), PString("")], childs:null },
					{ name: "P", props: [PString("UpVectorProperty"), PString("object"), PString(""), PString("")], childs:null },
					{ name: "P", props: [PString("Show"), PString("bool"), PString(""), PString(""), PInt(1)], childs:null },
					{ name: "P", props: [PString("NegativePercentShapeSupport"), PString("bool"), PString(""), PString(""), PInt(1)], childs:null },
					{ name: "P", props: [PString("DefaultAttributeIndex"), PString("int"), PString("Integer"), PString(""), PInt(-1)], childs:null },
					{ name: "P", props: [PString("Freeze"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("LODBox"), PString("bool"), PString(""), PString(""), PInt(0)], childs:null },
					{ name: "P", props: [PString("Lcl Translation"), PString("Lcl Translation"), PString(""), PString("A"), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("Lcl Rotation"), PString("Lcl Rotation"), PString(""), PString("A"), PInt(0), PInt(0), PInt(0)], childs:null },
					{ name: "P", props: [PString("Lcl Scaling"), PString("Lcl Scaling"), PString(""), PString("A"), PInt(1), PInt(1), PInt(1)], childs:null },
					{ name: "P", props: [PString("Visibility"), PString("Visibility"), PString(""), PString("A"), PInt(1)], childs:null },
					{ name: "P", props: [PString("Visibility Inheritance"), PString("Visibility Inheritance"), PString(""), PString(""), PInt(1)], childs:null },
				] }
			] }
		] };

		var materialCount = meshCount;
		var defMaterial : FbxNode = { name:"ObjectType", props:[PString("Material")], childs: [
			{ name: "Count", props: [PInt(materialCount)], childs: null },
			{ name: "PropertyTemplate", props: [PString("FbxSurfacePhong")], childs: [
					{ name:"Properties70", props: null, childs: [
					{ name: "P", props: [PString("ShadingModel"), PString("KString"), PString(""), PString(""), PString("Phong")], childs: null },
					{ name: "P", props: [PString("MultiLayer"), PString("bool"), PString(""), PString(""), PInt(0)], childs: null },
					{ name: "P", props: [PString("EmissiveColor"), PString("Color"), PString(""), PString("A"), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name: "P", props: [PString("EmissiveFactor"), PString("Number"), PString(""), PString("A"), PInt(1)], childs: null },
					{ name: "P", props: [PString("AmbientColor"), PString("Color"), PString(""), PString("A"), PFloat(0.2), PFloat(0.2), PFloat(0.2)], childs: null },
					{ name: "P", props: [PString("AmbientFactor"), PString("Number"), PString(""), PString("A"), PInt(1)], childs: null },
					{ name: "P", props: [PString("DiffuseColor"), PString("Color"), PString(""), PString("A"), PFloat(0.8), PFloat(0.8), PFloat(0.8)], childs: null },
					{ name: "P", props: [PString("DiffuseFactor"), PString("Number"), PString(""), PString("A"), PInt(1)], childs: null },
					{ name: "P", props: [PString("Bump"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name: "P", props: [PString("NormalMap"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name: "P", props: [PString("BumpFactor"), PString("double"), PString("Number"), PString(""), PInt(1)], childs: null },
					{ name: "P", props: [PString("TransparentColor"), PString("Color"), PString(""), PString("A"), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name: "P", props: [PString("TransparencyFactor"), PString("Number"), PString(""), PString("A"), PInt(0)], childs: null },
					{ name: "P", props: [PString("DisplacementColor"), PString("ColorRGB"), PString("Color"), PString(""), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name: "P", props: [PString("DisplacementFactor"), PString("double"), PString("Number"), PString(""), PInt(1)], childs: null },
					{ name: "P", props: [PString("VectorDisplacementColor"), PString("ColorRGB"), PString("Color"), PString(""), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name: "P", props: [PString("VectorDisplacementFactor"), PString("double"), PString("Number"), PString(""), PInt(1)], childs: null },
					{ name: "P", props: [PString("SpecularColor"), PString("Color"), PString(""), PString("A"), PFloat(0.2), PFloat(0.2), PFloat(0.2)], childs: null },
					{ name: "P", props: [PString("SpecularFactor"), PString("Number"), PString(""), PString("A"), PInt(1)], childs: null },
					{ name: "P", props: [PString("ShininessExponent"), PString("Number"), PString(""), PString("A"), PInt(20)], childs: null },
					{ name: "P", props: [PString("ReflectionColor"), PString("Color"), PString(""), PString("A"), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name: "P", props: [PString("ReflectionFactor"), PString("Number"), PString(""), PString("A"), PInt(1)], childs: null },
				]}
			] },
		] };

		var geometryCount = meshCount;
		var defGeometry : FbxNode = { name:"ObjectType", props:[PString("Geometry")], childs: [
			{ name: "Count", props: [PInt(geometryCount)], childs: null },
			{ name: "PropertyTemplate", props: [PString("FbxMesh")], childs: [
					{ name:"Properties70", props: null, childs: [
					{ name: "P", props: [PString("Color"), PString("ColorRGB"), PString("Color"), PString(""), PFloat(0.8), PFloat(0.8), PFloat(0.8)], childs: null },
					{ name: "P", props: [PString("BBoxMin"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name: "P", props: [PString("BBoxMax"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name: "P", props: [PString("Primary Visibility"), PString("bool"), PString(""), PString(""), PInt(1)], childs: null },
					{ name: "P", props: [PString("Casts Shadows"), PString("bool"), PString(""), PString(""), PInt(1)], childs: null },
					{ name: "P", props: [PString("Receive Shadows"), PString("bool"), PString(""), PString(""), PInt(1)], childs: null },
				] }
			] }
		] };

		var defCount = modelCount + materialCount + geometryCount + 1;
		var definitions : FbxNode = { name:"Definitions", props: null, childs: [
			{ name: "Version", props: [PInt(100)], childs: null },
			{ name: "Count", props: [PInt(defCount)], childs: null },
			defGlobalSettings,
			defModel,
			defMaterial,
			defGeometry
		]};

		return definitions;
	}

	function buildObjects(objects: Array<h3d.scene.Object>, objectTreeRoot : Dynamic) {
		var objectsNode : FbxNode = { name: "Objects", props: null, childs: [] };
		var input = { objectsNode : objectsNode, nextFreeId : 1 };

		function buildObject(object : h3d.scene.Object, input : Dynamic) {
			// Define uniques ids for representing model, geometry and material node
			var modelId = input.nextFreeId;
			var geometryId = input.nextFreeId + 1;
			var materialId = input.nextFreeId + 2;

			input.nextFreeId += 3;

			var mesh = Std.downcast(object, h3d.scene.Mesh);
			var hmdModel = Std.downcast(mesh.primitive, h3d.prim.HMDModel);
			var bufs = @:privateAccess hmdModel.getDataBuffers(hmdModel.data.vertexFormat);

			var vertices = new Array<Float>();
			var normals = new Array<Float>();
			var uvs = new Array<Float>();

			var idxVertex = 0;
			while (idxVertex < bufs.vertexes.length) {
				vertices.push(-bufs.vertexes[idxVertex]); // Change left hand to right hand
				vertices.push(bufs.vertexes[idxVertex + 1]);
				vertices.push(bufs.vertexes[idxVertex + 2]);

				normals.push(-bufs.vertexes[idxVertex + 3]);
				normals.push(bufs.vertexes[idxVertex + 4]);
				normals.push(bufs.vertexes[idxVertex + 5]);

				uvs.push(bufs.vertexes[idxVertex + 6]);
				uvs.push(bufs.vertexes[idxVertex + 7]);

				@:privateAccess idxVertex += hmdModel.data.vertexFormat.stride;
			}

			var indexes = new Array<Int>();
			var idxIndex = 0;
			while (idxIndex < bufs.indexes.length) {
				// We have to flip the order of vertex to change the facing direction of the triangle (because we swapped x axis
				// earlier to change from left hand to right hand)
				indexes.push(bufs.indexes[idxIndex + 1]);
				indexes.push(bufs.indexes[idxIndex]);

				// This is because the last index that close the polygon (in our case, we work with triangles, so the third)
				// need to be increased by one and then set to negative.
				// (This is because original index is XOR'ed with -1.)
				// We also need to keep indexes in range of vertices length
				indexes.push( -1 * (bufs.indexes[idxIndex + 2] + 1));

				idxIndex += 3;
			}

			var geometry : FbxNode = { name:"Geometry", props: [PInt(geometryId), PString('Geometry::${mesh.name}'), PString("Mesh")], childs:[
				{ name:"Vertices", props: [PFloats(vertices)], childs: null},
				{ name:"PolygonVertexIndex", props: [PInts(indexes)], childs: null},
				{ name:"GeometryVersion", props: [PInt(124)], childs: null},
				{ name:"LayerElementNormal", props: [PInt(0)], childs: [
					{ name: "Version", props: [ PInt(101) ], childs: null },
					{ name: "Name", props: [ PString("") ], childs: null },
					{ name: "MappingInformationType", props: [ PString("ByVertice") ], childs: null },
					{ name: "ReferenceInformationType", props: [ PString("Direct") ], childs: null },
					{ name: "Normals", props: [ PFloats(normals) ], childs: null },
				]},
				{ name:"LayerElementUV", props: [PInt(0)], childs: [
					{ name: "Version", props: [ PInt(101) ], childs: null },
					{ name: "Name", props: [ PString("UVMap") ], childs: null },
					{ name: "MappingInformationType", props: [ PString("ByVertice") ], childs: null },
					{ name: "ReferenceInformationType", props: [ PString("Direct") ], childs: null },
					{ name: "UV", props: [ PFloats(uvs) ], childs: null },
				]},
				{ name:"LayerElementMaterial", props: [PInt(0)], childs: [
					{ name: "Version", props: [ PInt(101) ], childs: null },
					{ name: "Name", props: [ PString("") ], childs: null },
					{ name: "MappingInformationType", props: [ PString("AllSame") ], childs: null },
					{ name: "ReferenceInformationType", props: [ PString("IndexToDirect") ], childs: null },
					{ name: "Materials", props: [ PInts( [ 0 ] ) ], childs: null },
				]},
				{ name:"Layer", props: [PInt(0)], childs: [
					{ name: "Version", props: [ PInt(100) ], childs: null },
					{ name: "LayerElement", props: null, childs: [
						{ name: "Type", props: [ PString("LayerElementNormal") ], childs: null },
						{ name: "TypedIndex", props: [ PInt(0) ], childs: null },
					] },
					{ name: "LayerElement", props: null, childs: [
						{ name: "Type", props: [ PString("LayerElementMaterial") ], childs: null },
						{ name: "TypedIndex", props: [ PInt(0) ], childs: null },
					] },
					{ name: "LayerElement", props: null, childs: [
						{ name: "Type", props: [ PString("LayerElementUV") ], childs: null },
						{ name: "TypedIndex", props: [ PInt(0) ], childs: null },
					] },
				]}
			] };

			var t = object.getTransform();
			t = object.defaultTransform.multiplied(t);

			t._12 = -t._12;
			t._13 = -t._13;
			t._21 = -t._21;
			t._31 = -t._31;
			t._41 = -t._41;

			var model : FbxNode = { name:"Model", props: [PInt(modelId), PString('Model::${mesh.name}'), PString("Mesh")], childs:[
				{ name:"Version", props:[ PInt(232)], childs:null },
				{ name:"Properties70", props: null, childs: [
					{ name:"P", props:[PString("InheritType"), PString("enum"), PString(""), PString(""), PInt(1)], childs: null },
					{ name:"P", props:[PString("DefaultAttributeIndex"), PString("int"), PString("Integer"), PString(""), PInt(0)], childs: null },
					{ name:"P", props:[PString("Lcl Translation"), PString("Lcl Translation"), PString(""), PString("A"), PFloat(t.getPosition().x), PFloat(t.getPosition().y), PFloat(t.getPosition().z)], childs: null },
					{ name:"P", props:[PString("Lcl Rotation"), PString("Lcl Rotation"), PString(""), PString("A"), PFloat(Math.radToDeg(t.getEulerAngles().x)), PFloat(Math.radToDeg(t.getEulerAngles().y)), PFloat(Math.radToDeg(t.getEulerAngles().z))], childs: null },
					{ name:"P", props:[PString("Lcl Scaling"), PString("Lcl Scaling"), PString(""), PString("A"), PFloat(t.getScale().x), PFloat(t.getScale().y), PFloat(t.getScale().z)], childs: null },
				]}
			] };

			var material : FbxNode = { name:"Material", props: [PInt(materialId), PString("Material::Material"), PString("")], childs:[
				{ name: "Version", props: [PInt(102)], childs: null },
				{ name: "ShadingModel", props: [PString("phong")], childs: null },
				{ name: "MultiLayer", props: [PInt(0)], childs: null },
				{ name: "Properties70", props: null, childs: [
					{ name:"P", props: [PString("EmissiveColor"), PString("Color"), PString(""), PString("A"), PInt(1), PInt(1), PInt(1)], childs: null },
					{ name:"P", props: [PString("EmissiveFactor"), PString("Number"), PString(""), PString("A"), PInt(0)], childs: null },
					{ name:"P", props: [PString("AmbientColor"), PString("Color"), PString(""), PString("A"), PFloat(0.5), PFloat(0.5), PFloat(0.5)], childs: null },
					{ name:"P", props: [PString("AmbientFactor"), PString("Number"), PString(""), PString("A"), PInt(0)], childs: null },
					{ name:"P", props: [PString("DiffuseColor"), PString("Color"), PString(""), PString("A"), PFloat(0.8), PFloat(0.8), PFloat(0.8)], childs: null },
					{ name:"P", props: [PString("BumpFactor"), PString("double"), PString("Number"), PString(""), PInt(0)], childs: null },
					{ name:"P", props: [PString("SpecularColor"), PString("Color"), PString(""), PString("A"), PFloat(0.8), PFloat(0.8), PFloat(0.8)], childs: null },
					{ name:"P", props: [PString("SpecularFactor"), PString("Number"), PString(""), PString("A"), PInt(25)], childs: null },
					{ name:"P", props: [PString("ShininessExponent"), PString("Number"), PString(""), PString("A"), PInt(25)], childs: null },
					{ name:"P", props: [PString("ReflectionColor"), PString("Color"), PString(""), PString("A"), PFloat(0.8), PFloat(0.8), PFloat(0.8)], childs: null },
					{ name:"P", props: [PString("ReflectionFactor"), PString("Number"), PString(""), PString("A"), PInt(0)], childs: null },
					{ name:"P", props: [PString("Shininess"), PString("Number"), PString(""), PString("A"), PInt(25)], childs: null },
					{ name:"P", props: [PString("Emissive"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name:"P", props: [PString("Ambient"), PString("Vector3D"), PString("Vector"), PString(""), PInt(0), PInt(0), PInt(0)], childs: null },
					{ name:"P", props: [PString("Diffuse"), PString("Vector3D"), PString("Vector"), PString(""), PFloat(0.8), PFloat(0.8), PFloat(0.8)], childs: null },
					{ name:"P", props: [PString("Specular"), PString("Vector3D"), PString("Vector"), PString(""), PFloat(0.2), PFloat(0.2), PFloat(0.2)], childs: null },
					{ name:"P", props: [PString("Opacity"), PString("double"), PString("Number"), PString(""), PInt(1)], childs: null },
					{ name:"P", props: [PString("Reflectivity"), PString("double"), PString("Number"), PString(""), PInt(0)], childs: null }
				] },
			] };

			input.objectsNode.childs.push(geometry);
			input.objectsNode.childs.push(model);
			input.objectsNode.childs.push(material);
		}

		function build(objects: Array<h3d.scene.Object>, input : Dynamic, parent : Dynamic) {
			for (o in objects) {
				// We're not supporting anything except meshes for now
				var mesh = Std.downcast(o, h3d.scene.Mesh);
				if (mesh == null)
					continue;

				var objectLeaf = { id: input.nextFreeId, children : [] };
				parent.children.push(objectLeaf);

				buildObject(o, input);
				build(@:privateAccess o.children, input, objectLeaf);
			}
		}

		build(objects, input, objectTreeRoot);
		return input.objectsNode;
	}

	function buildConnections(objectTree : Dynamic) {
		// C stands for "Connection"
		// OO stands for "Object to Object" meaning the connection is between two objects
		// Then there's ids of object that are linked

		var connections : FbxNode = { name:"Connections", props: null, childs: []};

		function addConnexion(parentId : Int, objectTree : Dynamic) {
			if (objectTree.id != 0) {
				connections.childs.push({ name:"C", props: [ PString("OO"), PInt(objectTree.id), PInt(parentId) ], childs: null });
				connections.childs.push({ name:"C", props: [ PString("OO"), PInt(objectTree.id + 1), PInt(objectTree.id) ], childs: null });
				connections.childs.push({ name:"C", props: [ PString("OO"), PInt(objectTree.id + 2), PInt(objectTree.id) ], childs: null });
			}

			for (idx in 0...objectTree.children.length)
				addConnexion(objectTree.id, objectTree.children[idx]);
		}

		addConnexion(-1, objectTree);
		return connections;
	}

	public function write(objects: Array<h3d.scene.Object>) {
		var old = out;
		var header = new haxe.io.BytesOutput();
		out = header;

		function clone(obj : h3d.scene.Object, ?into : h3d.scene.Mesh) : h3d.scene.Mesh {
			var o : h3d.scene.Mesh = null;
			if (into != null) {
				o = into;
			}
			else {
				var m = Std.downcast(obj, h3d.scene.Mesh);
				o = new h3d.scene.Mesh(m.primitive, m.material, null);
			}

			o.x = obj.x;
			o.y = obj.y;
			o.z = obj.z;
			o.scaleX = obj.scaleX;
			o.scaleY = obj.scaleY;
			o.scaleZ = obj.scaleZ;
			@:privateAccess o.qRot.load(obj.qRot);
			o.name = obj.name;
			o.follow = obj.follow;
			o.followPositionOnly = obj.followPositionOnly;
			o.visible = obj.visible;
			if( obj.defaultTransform != null ) {
				if (o.defaultTransform != null)
					o.defaultTransform = o.defaultTransform.multiplied(obj.defaultTransform.clone());
				else
					o.defaultTransform = obj.defaultTransform.clone();
			}
			return o;
		}

		function deepClone(m : h3d.scene.Mesh, ?parent : h3d.scene.Mesh) {
			var copy = clone(m);

			if (parent != null)
				parent.addChild(copy);

			for (child in @:privateAccess m.children) {
				var childMesh = Std.downcast(child, h3d.scene.Mesh);

				if (childMesh != null)
					deepClone(childMesh, copy);
			}

			return copy;
		}

		function applyInverseDefaultTransform(obj : h3d.scene.Object, defaultTransform : h3d.Matrix) {
			if (defaultTransform != null) {
				var t = obj.getTransform().multiplied(defaultTransform.getInverse());
				obj.x = t.getPosition().x;
				obj.y = t.getPosition().y;
				obj.z = t.getPosition().z;

				var q : h3d.Quat = new h3d.Quat();
				q.initRotation(t.getEulerAngles().x, t.getEulerAngles().y, t.getEulerAngles().z);
				@:privateAccess obj.qRot.w = q.w;
				@:privateAccess obj.qRot.x = q.x;
				@:privateAccess obj.qRot.y = q.y;
				@:privateAccess obj.qRot.z = q.z;

				obj.scaleX = t.getScale().x;
				obj.scaleY = t.getScale().y;
				obj.scaleZ = t.getScale().z;
			}
		}

		var roots : Array<h3d.scene.Mesh> = [];
		function extractMeshes( o : h3d.scene.Object, ?parent : h3d.scene.Mesh) {
			var m = Std.downcast(o, h3d.scene.Mesh);

			// If this object isn't a mesh, we have to find into his children which mesh(s)
			// is/are associated to it
			if (m == null) {
				var associatedMesh : h3d.scene.Object = null;

				for (c in @:privateAccess o.children)
					if (c.name == "root") // Associated mesh is named root (see makeInstance() of Model)
						associatedMesh = c;

				if (associatedMesh != null) {
					var m2 = Std.downcast(associatedMesh, h3d.scene.Mesh);
					var alreadyExtracted = new Array<h3d.scene.Object>();

					if (m2 != null) {
						// Single mesh object
						var mesh = clone(m2);

						// Since it's the parent object that is holding informations
						// apply it on mesh object
						clone(o, mesh);

						if (parent == null)
							roots.push(mesh);
						else {
							parent.addChild(mesh);
							applyInverseDefaultTransform(mesh, parent.defaultTransform);
						}

						parent = cast mesh;
						alreadyExtracted.push(m2);
					}
					else {
						// Multiple mesh object
						var randomRootMesh : h3d.scene.Mesh = null;
						for (c in @:privateAccess associatedMesh.children) {
							var mesh = Std.downcast(c, h3d.scene.Mesh);

							if (mesh != null) {
								var copy = deepClone(mesh);
								clone(o, copy);

								if (parent == null)
									roots.push(copy);
								else {
									parent.addChild(copy);
									applyInverseDefaultTransform(copy, parent.defaultTransform);
								}
								randomRootMesh = copy;
							}
						}

						parent = randomRootMesh;
						alreadyExtracted.push(associatedMesh);
					}

					// Continue to extract meshes on other objects
					for (c in @:privateAccess o.children) {
						if (alreadyExtracted.contains(c))
							continue;

						extractMeshes(c, parent);
					}
				}
				else {
					// We're in the case where there is multiple meshes
					// and no children
					for (c in @:privateAccess o.children) {
						var mesh = Std.downcast(c, h3d.scene.Mesh);

						if (mesh != null) {
							var copy = deepClone(mesh);
							clone(o, copy);

							if (parent == null)
								roots.push(copy);
							else {
								parent.addChild(copy);
								applyInverseDefaultTransform(copy, parent.defaultTransform);
							}
						}
					}
				}
			}
			else {
				var copy = clone(m);
				if (parent == null)
					roots.push(copy);
				else {
					parent.addChild(copy);
					applyInverseDefaultTransform(copy, parent.defaultTransform);
				}
			}
		}

		// We have to extract meshes object from the incomming objects to remove
		// non-needed parent objects that are created in hide in make instance
		// of model
		for (o in objects)
			extractMeshes(o);

		writeHeader();
		writeNode(buildGlobalSettings());
		writeNode(buildDefinitions(cast roots));

		var objectTreeRoot = { id: 0, children: [] };
		writeNode(buildObjects(cast roots, objectTreeRoot));
		writeNode(buildConnections(objectTreeRoot));

		var bytes = header.getBytes();
		out = old;

		out.write(bytes);
	}
}
