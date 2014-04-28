package selftest.cases;
import haxe.PosInfos;
import nanotest.NanoTestCase;
import nanotest.NanoTestRunner;
import selftest.cases.SelfTestCase.FailureTestCase;
import selftest.cases.SelfTestCase.TestMode;

/**
 * ...
 * @author shohei909
 */
class SelfTestCase extends NanoTestCase{
	public var testMode:TestMode;
	public var expectedFailQue:Array<String>;

	public function testSuccess() {
		testMode = TestMode.SUCCESS;
		
		var runner = new NanoTestRunner();
		runner.print = dummyPrint;
		var successCase = new SuccessTestCase();
		runner.print = dummyPrint;
		runner.add( successCase );
		assertTrue( runner.run() );
		assertEquals( 4, successCase.setupCount );
		assertEquals( 4, successCase.tearDownCount );
		assertEquals( 1, successCase.globalSetupCount );
		assertEquals( 1, successCase.globalTearDownCount );
		
		assertEquals( '"aa"', NanoTestCase.format( "aa" ) );
		assertEquals( "1", NanoTestCase.format( 1 ) );
	}
	
	public function testFailure() {
		testMode = FAILURE;
		expectedFailQue = [];
		
		var runner = new NanoTestRunner( onError );
		runner.print = dummyPrint;
		runner.add( new FailureTestCase( this ) );
		assertFalse( runner.run() );
		assertEquals( 0, expectedFailQue.length );
	}
	
	public function testError() {
		testMode = ERROR;
		expectedFailQue = [];
		var runner = new NanoTestRunner( onError );
		runner.print = dummyPrint;
		runner.add( new ErrorTestCase( this ) );
		assertFalse( runner.run() );
		assertEquals( 0, expectedFailQue.length );
	}
	
	function dummyPrint( string:String ) {}
	
	function onError( string:String, posInfos:PosInfos ) {
		switch( testMode ) {
			case SUCCESS:
				fail( string, posInfos );
			case FAILURE:
				var message = expectedFailQue.shift();
				assertEquals( message, string, posInfos );
			case ERROR:
				if( string != "Called from" ){
					var message = expectedFailQue.shift();
					assertEquals( message, string, posInfos );
				}
		}
	}
	
	public function expectFail( string:String ) {
		expectedFailQue.push( "Test failed : " + string );
	}
	
	public function expectError( string:String ) {
		expectedFailQue.push( "exception thrown : " + string );
	}
}

enum TestMode {
	SUCCESS;
	FAILURE;
	ERROR;
}

enum Tree {
	LEAF( object:Dynamic );
	NODE( tree1:Tree, tree2:Tree );
}

class SuccessTestCase extends NanoTestCase {
	public var setupCount:Int;
	public var tearDownCount:Int;
	public var globalSetupCount:Int;
	public var globalTearDownCount:Int;
	
	public function new() {
		super();
		setupCount = 0;
		tearDownCount = 0;
		globalSetupCount = 0;
		globalTearDownCount = 0;
		
		assertTrue( true );
		assertFalse( false );
	}
	
	public function testSuccess() {
		assertTrue( true );
		assertFalse( false );
		assertEquals( 5.0, 1 + 4 );
		assertEquals( "hoge" + "fuga", "hogefuga" );
		assertEquals( this, this );
		assertEquals( setupCount, tearDownCount + 1 );
		assertEquals( globalSetupCount, 1 );
		assertEquals( globalTearDownCount, 0 );
		assertEquals( LEAF(0.1), LEAF(0.1) );
	}
	
	public function testSuccess2() {
		assertEquals( SUCCESS, TestMode.SUCCESS );
		assertEquals( NODE( LEAF("hoge"), LEAF(1) ), NODE( LEAF("hoge"), LEAF(1.0) ) );
		assertEquals( LEAF(this), LEAF(this) );
		assertEquals( setupCount, tearDownCount + 1 );
		assertEquals( globalSetupCount, 1 );
		assertEquals( globalTearDownCount, 0 );
	}
	
	public function testSuccess3() {
		assertThrows( throwError, isThrowSuccess );
		assertThrows( throwError );
		assertEquals( setupCount, tearDownCount + 1 );
		assertEquals( globalSetupCount, 1 );
		assertEquals( globalTearDownCount, 0 );
	}
	
	public function testSuccess4() {
		assertEquals( 1.0, 1 );
		
		var obj1 = {}, obj2 = {};
		assertNotEquals( LEAF(obj1), LEAF(obj2) );
		assertEquals( LEAF(obj1), LEAF(obj1) );
	}
	
	public function throwError() {
		throw "error test";
	}
	
	public function isThrowSuccess( string:String ) {
		return (string == "error test");
	}
	
	override public function globalSetup() {
		globalSetupCount++;
	}
	
	override public function globalTearDown() {
		globalTearDownCount++;
	}
	
	override public function setup() {
		setupCount++;
	}
	
	override public function tearDown() {
		tearDownCount++;
	}
}

class FailureTestCase extends NanoTestCase {
	var parent:SelfTestCase;
	
	public function new( parent ) {
		this.parent = parent;
		super();
		
		parent.expectFail( NanoTestCase.ASSERT_FALSE_ERROR );
		assertFalse( true );
		
		parent.expectFail( NanoTestCase.ASSERT_TRUE_ERROR );
		assertTrue( false );
	}
	
	public function testFailure() {
		parent.expectFail( NanoTestCase.ASSERT_FALSE_ERROR );
		assertFalse( true );
		
		parent.expectFail( NanoTestCase.ASSERT_TRUE_ERROR );
		assertTrue( false );
		
		var obj1 = {};
		var obj2 = {};
		parent.expectFail( NanoTestCase.ASSERT_EQUALS_ERROR( obj1, obj2 ) );
		assertEquals( obj1, obj2 );
		
		parent.expectFail( NanoTestCase.ASSERT_EQUALS_ERROR( LEAF(obj1), LEAF(obj2) ) );
		assertEquals( LEAF(obj1), LEAF(obj2) );
		
		parent.expectFail( NanoTestCase.ASSERT_NOT_EQUALS_ERROR( 0, 0 ) );
		assertNotEquals( 0, 0 );
	}
	
	public function testFailureLabel() {
		parent.expectFail( NanoTestCase.ASSERT_FALSE_ERROR + " [F]" );
		assertFalse( true ).label("F");
		
		parent.expectFail( NanoTestCase.ASSERT_TRUE_ERROR + ' [1] [${true}]' );
		assertTrue( false ).label(1).label(true);
		
		var obj1 = {};
		var obj2 = {};
		parent.expectFail( NanoTestCase.ASSERT_EQUALS_ERROR( obj1, obj2 ) + ' [$obj1]' );
		assertEquals( obj1, obj2 ).label(obj1);
		
		parent.expectFail( NanoTestCase.ASSERT_NOT_EQUALS_ERROR( 0, 0 ) + " [hoge]");
		assertNotEquals( 0, 0 ).label("hoge");
	}
}

class ErrorTestCase extends NanoTestCase {
	var parent:SelfTestCase;
	
	public function new( parent ) {
		this.parent = parent;
		super();
	}
	
	public function testFailure() {
		parent.expectError( "exp" );
		throw "exp";
	}
	
	public function testFailure2() {
		parent.expectFail( NanoTestCase.ASSERT_THROWS_ERROR );
		assertThrows( nothing, isThrowSuccess );
		parent.expectFail( NanoTestCase.ASSERT_THROWS_ERROR );
		assertThrows( nothing );
		
		parent.expectFail( NanoTestCase.ASSERT_THROWS_ILLEGAL_EXCEPTION( "fail" ) );
		parent.expectError( "fail" );
		assertThrows( throwError, isThrowSuccess );
	}
	
	public function testFailureLabel() {
		parent.expectFail( NanoTestCase.ASSERT_THROWS_ERROR  + " [-1]");
		assertThrows( nothing, isThrowSuccess ).label(-1);
		parent.expectFail( NanoTestCase.ASSERT_THROWS_ERROR  + " [0]");
		assertThrows( nothing ).label(0);
		
		parent.expectFail( NanoTestCase.ASSERT_THROWS_ILLEGAL_EXCEPTION( "fail" ) + " [f] [!]" );
		parent.expectError( "fail" );
		assertThrows( throwError, isThrowSuccess ).label("f").label("!");
	}
	
	public function nothing() {}
	
	public function throwError() {
		throw "fail";
	}
	
	public function isThrowSuccess( string:String ) {
		return (string == "error test");
	}
}