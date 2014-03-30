package src\sample\nanotest\sample;

import haxe.Timer;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import nanotest.NanoTestRunner;
import nanotest.NanoTestCase;
 
class AsyncTestSample {
	static var finishCount = 0; 
	static var asyncCases:Array<NanoTestCase> = [];
	
    static function main() {
		asyncCases.push( new AsyncCase(onFinished) );
        onFinished();
	}
	
	static function onFinished() {
		finishCount++;
		if ( finishCount == asyncCases.length + 1 ) {
			var runner = new NanoTestRunner();
			for( c in asyncCases ){
				runner.add( c );
			}
			runner.run();
		}
	}
}
 
class AsyncCase extends NanoTestCase {
	var finished:Void->Void;
	
	public function new( finished ) {
		super();
		this.finished = finished;
		
		#if sys
		Sys.sleep( 0.01 );
		asyncFailure();
		#else
		Timer.delay( asyncFailure, 10 );
		#end
	}
	
    public function asyncFailure() {
        assertEquals( "B", "A" );
		finished();
    }
}