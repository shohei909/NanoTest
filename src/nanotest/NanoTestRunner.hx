package nanotest;
import haxe.CallStack;
import haxe.Log;
import haxe.PosInfos;
import haxe.unit.TestRunner;

#if macro
import haxe.macro.Context;
import haxe.io.Bytes;
import sys.io.File;
import sys.FileSystem;
#end

class NanoTestRunner {
	
	#if macro
	static public var resultLineERegs:Array<NanoTestResultLineDef> = [
		{ //Called from 
			ereg 	: ~/^(Called from) ([^*?"<>|]+) line ([1-9][0-9]*)/,
			pos 	: [2, 3, 1],
		},
		{ //haxe.unit
			ereg 	: ~/^ERR[:] ([^*?"<>|]+)[:]([1-9][0-9]*)[(][a-zA-Z.]+[)] [-] (.+)/, 
			pos 	: [1, 2, 3],
		},
		{ //NanoTest
			ereg 	: ~/^([^*?"<>|]+)[:]([1-9][0-9]*)[:] ((exception thrown |Test failed |Called from).*)/, 
			pos 	: [1, 2, 3],
			getFile : function (str:String, ereg) {
				if (str.substr(str.length - 3) == ".hx") return str;
				var segs = str.split("::");
				if (segs.length == 1) return str;
				var str = segs[0];
				var segs = str.split(".");
				return segs.join("/") + ".hx";
			}
		}, 
		{ //MUnit
			ereg 	: ~/^\s*[A-Z]+[:] massive\.munit\.[a-zA-Z.]*Exception[:] (.*) at ([^*?"<>|]+) [(]([1-9][0-9]*)[)]/, 
			pos 	: [2, 3, 1],
			getFile : function (str:String, ereg) {
				if (str.substr(str.length - 3) == ".hx") return str;
				var str = str.split("#")[0];
				var segs = str.split(".");
				return segs.join("/") + ".hx";
			}
		}
	];
	
	static public function readResult(file:String, sourceDir:Array<String>, ?label:String) {
		Sys.println( "" );
		Sys.println( if (label != null) '== $label Result ==' else '== Result ==' );
		
		var r = File.read(file);
		var segs = ~/\r\n|\n|\r/g.split(r.readAll().toString());
		sourceDir.push(null);
		
		var fail = false;
		
		for (str in segs) {
			var printed = false;
			Sys.println("|\t" + str);
			
			for (e in resultLineERegs) {
				var ereg = e.ereg;
				if (ereg.match(str)) {
					var p = ereg.matched(e.pos[0]);
					var line = Std.parseInt(ereg.matched(e.pos[1]));
					var msg = ereg.matched(e.pos[2]);
					if (e.getFile != null) p = e.getFile(p, ereg);
					if (label != null) msg = '($label) $msg';
					
					for (dir in sourceDir) {
						var file = p;
						if (dir != null) file = '$dir/$file';
						if (FileSystem.exists(file))
						{
							try {
								warning(msg, { fileName : file, lineNumber : line, className : null, methodName : null } );
								fail = true;
								printed = true;
								break;
							} catch (d :Dynamic) {
							}
						}
					}
					
					if (printed) break;
				}
			}
		}
		
		
		if (Context.defined("result_exit_code") && fail) Sys.exit(1);
	}
	#end
	
	public var cases(default, null):Array<NanoTestCase>;
	
	#if php 
	public function hprint( d ) { TestRunner.print( d ); }
	#end
	
	public var printError:String->PosInfos->Void;
	
	#if flash
	static var traceData:String = "";
	public dynamic function print(d:Dynamic) { 
		traceData += Std.string(d);
		TestRunner.print(d); 
	}
	#else
	public dynamic function print(d:Dynamic) { 
		TestRunner.print(d); 
	}
	#end
	
	public function new( ?printError:String->PosInfos->Void ) {
		cases = [];
		
		if ( printError == null ) {
			this.printError = NanoTestRunner.warning;
		} else {
			this.printError = printError;
		}
	}
	
	public function add( testCase:NanoTestCase ) {
		cases.push( testCase );
	}
	
	public function run() : Bool {
		#if flash
		var oldTrace = traceData;
		traceData = "";
		#end
		
		var results = [];
		for ( c in cases ) {
			var rs = c.run( print );
			for ( r in rs ) {
				results.push( r );
			}
		}
		
		var failures = 0;
		for ( result in results ){
			if (result.failed){
				print("* " + result.className + "::" + result.method + "()\n");
				
				for ( status in result.status ) {
					switch(status) {
						case SUCCESS(_):
						case FAIL(message, posInfos):
							printError( "Test failed : " + message, posInfos );
						case ERROR(message, callStack):
							var first = true;
							for ( item in callStack ) {
								var c = "Called from";
								switch( item ) {
									case CFunction:
										print(c + " : a C function\n");
									case Module(m):
										print(c + " : module " + m + "\n");
									case FilePos(s,file,line):
										var posInfos = {
											fileName : file,
											lineNumber : line,
											className : result.className,
											methodName : result.method,
										}
										if (first){ 
											printError( "exception thrown : " + message, posInfos );
											first = false;
										} else {
											printError( c , posInfos );
										}
									case Method(cname,meth):
										print(c + " : " + cname +  "." + meth + "\n");
									#if (haxe_ver >= 3.01)
									case LocalFunction(n):
									#else
									case Lambda(n):
									#end
										print(c + " : local function #" + n + "\n");
								}
							}
							
							if (first) {
								printError( 
									"exception thrown : " + message,
									result.testCase.posInfos
								);
							}
					}
				}
				
				print( "\n" );
				failures++;
			}
		}
		
		if (failures == 0)
			print("OK ");
		else
			print("FAILED ");
		
		print(results.length + " tests, " + failures + " failed, " + (results.length - failures) + " success\n");
		
		#if flash
		if (traceData != "") trace("NanoTest Reslut Output\n" + traceData);
		traceData = oldTrace;
		#end
		
		return (failures == 0);
	}
	
	static public function error( message:String, position:PosInfos ) {
		#if macro
		Context.error( message, posInfosToPosition(position) );
		#elseif flash
		TestRunner.print(fileFromPosInfos(position)+":"+position.lineNumber+": "+message+"\n");
		#end
		#if flash
		traceData += Std.string(fileFromPosInfos(position)+":"+position.lineNumber+": "+message+"\n");
		#end
	}
	
	static public function warning( message:String, position:PosInfos ) {
		#if macro
		Context.warning(message, posInfosToPosition(position));
		#else
		TestRunner.print(fileFromPosInfos(position)+":"+position.lineNumber+": "+message+"\n");
		#end
		#if flash
		traceData += Std.string(fileFromPosInfos(position)+":"+position.lineNumber+": "+message+"\n");
		#end
	}
	
	static function fileFromPosInfos(posInfos:PosInfos ) {
		if (posInfos.className == null) return posInfos.fileName;
		if (posInfos.fileName == null) return null;
		
		var fsegs = ~/\\|\//.split(posInfos.fileName);
		if (fsegs.length > 1) return posInfos.fileName;
		
		var f = fsegs.pop();
		
		if (f.substr(f.length - 3) != ".hx") return posInfos.fileName;
		
		var segs = posInfos.className.split(".");
		segs.pop();
		segs.push( f );
		return segs.join("/");
	}
	
	static function posInfosToPosition( posInfos:PosInfos ) {
		#if macro
		var file = File.read( posInfos.fileName ).readAll().toString();
		var ereg = ~/\r\n|\r|\n/;
		
		var min = 0;
		for ( i in 0...posInfos.lineNumber - 1 ) {
			ereg.match( file );
			var pos = ereg.matchedPos();
			min += pos.pos + pos.len;
			file = ereg.matchedRight();
		}
		
		var max = min + 
			if( ereg.match( file ) )
				ereg.matchedPos().pos;
			else 
				file.length;
				
		return Context.makePosition({
			file : FileSystem.fullPath(posInfos.fileName), 
			min : min, 
			max : max,
		});
		
		#else
		return {
			file : posInfos.fileName, min : 0, max : 0,
		}
		#end
	}
}

typedef NanoTestResultLineDef = {
	ereg 		: EReg,
	pos			: Array<Int>,
	?getFile 	: String->EReg->String,
}
