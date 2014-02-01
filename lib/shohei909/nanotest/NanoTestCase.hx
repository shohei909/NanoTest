package shohei909.nanotest;
import haxe.CallStack;
import haxe.macro.Context;
import haxe.PosInfos;

/**
 * ...
 * @author shohei909
 */
class NanoTestCase {
	static inline var ASSERT_TRUE_ERROR = "expected true but was false";
	static inline var ASSERT_FALSE_ERROR = "expected false but was true";
	static inline var ASSERT_THROWS_ERROR = "expected to throw exception but didn't";
	static inline function ASSERT_THROWS_ILLEGAL_EXCEPTION( actual:Dynamic ) {
		return 'catched illeagal exception ${format(actual)}';
	}
	static inline function ASSERT_EQUALS_ERROR( expected:Dynamic, actual:Dynamic ) {
		return 'expected ${format(expected)} but was ${format(actual)}';
	}
	static function format( d:Dynamic ) {
		return 
			if ( Std.is( d, String ) ) 
				'"$d"'
			else 
				'$d';
	}
	
	var currentResult:NanoTestResult;
	public var posInfos(default, null):PosInfos;
	public function new( ?posInfos:PosInfos ) {
		this.posInfos = posInfos;
	}
	
	public function globalTearDown() {}
	public function globalSetup() {}
	public function tearDown() {}
	public function setup() {}
	
	public function run( print:Dynamic->Void ) {
		var results = [];
		
		var cl = Type.getClass(this);
		var fields = Type.getInstanceFields(cl);
		
		print( "Class: " + Type.getClassName(cl) + " ");
		
		globalSetup();
		for ( fname in fields ){
			var field = Reflect.field(this, fname);
			if ( StringTools.startsWith(fname,"test") && Reflect.isFunction(field) ){
				setup();
				
				currentResult = {
					className : Type.getClassName(cl),
					method : fname,
					testCase : this,
					error : false,
					failed : false,
					status : [],
				}
				
				try {
					field();
				}catch ( e : Dynamic ) {
					error( e );
				}
				
				if (currentResult.error) {
					print( "E" );
				} else if (currentResult.failed) {
					print( "F" );
				} else {
					print( "." );
				}
				
				results.push( currentResult );
				tearDown();
			}
		}
		globalTearDown();
		print( "\n" );
		return results;
	}
	
	
	public function assertTrue( b:Bool, ?p : PosInfos ) : Void {
		if (b == false) {
			fail( ASSERT_TRUE_ERROR, p );
		} else {
			success( p );
		}
	}

	public function assertFalse( b:Bool, ?p : PosInfos ) : Void {
		if (b == true){
			fail( ASSERT_FALSE_ERROR, p );
		} else {
			success( p );
		}
	}

	public function assertEquals<T>( expected: T , actual: T,  ?p : PosInfos ) : Void {
		if ( Reflect.isEnumValue(expected) ){
			if (!Type.enumEq(actual, expected)){
				fail( ASSERT_EQUALS_ERROR(expected, actual), p );
			} else {
				success( p );
			}
		} else { 
			if (actual != expected){
				fail( ASSERT_EQUALS_ERROR(expected, actual), p );
			} else {
				success( p );
			}
		}
	}
	
	public function assertThrows ( func:Void->Void, ?isSuccess:Dynamic->Bool, ?p : PosInfos ){
		try {
			func();
		} catch ( d:Dynamic ) {
			if ( isSuccess == null || isSuccess( d ) ) {
				success( p );
			} else {
				fail( ASSERT_THROWS_ILLEGAL_EXCEPTION( d ), p );
				error( d );
			}
			return;
		}
		
		fail( ASSERT_THROWS_ERROR, p );
	}
	
	public function fail( message:String, ?p:PosInfos ) : Void {
		currentResult.failed = true;
		currentResult.status.push( NanoTestStatus.FAIL( message, p ) );
	}
	
	public function success( ?p:PosInfos ) : Void {
		currentResult.status.push( NanoTestStatus.SUCCESS( p ) );
	}
	
	public function error( e:Dynamic ) {
		currentResult.failed = true;
		currentResult.error = true;
		
		#if js
		var message = e +" ["+e.message+"]";
		#else
		var message = Std.string( e );
		#end
		
		currentResult.status.push( NanoTestStatus.ERROR( message, CallStack.exceptionStack() ) );
	}
}