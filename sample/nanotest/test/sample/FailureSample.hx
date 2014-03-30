package sample;

import nanotest.NanoTestRunner;
import nanotest.NanoTestCase;

class FailureSample{
	static public function main() {
		var runner = new NanoTestRunner();
		runner.add( new FailureCase() );
		runner.run();
	}
}

class FailureCase extends NanoTestCase {
	public function testBasic() {
		assertEquals( "AB", "A" + "B");
		assertEquals( 3, 1 + 1 );
		assertEquals( 5, 2 + 2 );
		throw "error test";
	}
}
