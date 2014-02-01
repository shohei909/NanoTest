package shohei909.nanotest;
import haxe.CallStack;
import haxe.Log;
import haxe.PosInfos;
import haxe.unit.TestRunner;

#if macro
import haxe.macro.Context;
import sys.io.File;
import haxe.io.Bytes;
#end

class NanoTestRunner {
	public var cases(default,null):Array<NanoTestCase>;
	public var print:Dynamic->Void;
	public var printError:String->PosInfos->Void;
	
	public function new( ?printError:String->PosInfos->Void ) {
		cases = [];
		
		this.print = TestRunner.print;
		
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
										print(c + " : a C function");
									case Module(m):
										print(c + " : module " + m);
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
										print(c + " : " + cname +  "." + meth);
									case Lambda(n):
										print(c + " : local function #" + n);
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
		
		return (failures == 0);
	}
	
	static public function error( message:String, position:PosInfos ) {
		#if macro
		return Context.error( message, posInfosToPosition(position) );
		#else 
		return Log.trace( message, position );
		#end
	}
	
	static public function warning( message:String, position:PosInfos ) {
		#if macro
		return Context.warning( message, posInfosToPosition(position) );
		#else 
		return Log.trace( message, position );
		#end
	}
	
	
	static function posInfosToPosition( posInfos:PosInfos ) {
		#if macro
		var file = File.read( posInfos.fileName ).readAll().toString();
		var ereg = ~/(\r\n|\r|\n)/;
		
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
				
		return Context.makePosition( {
			file : posInfos.fileName, min : min, max : max,
		});
		#else
		return {
			file : posInfos.fileName, min : 0, max : 0,
		}
		#end
	}
}