package sample;
import sample.FailureSample.FailureCase;
import shohei909.nanotest.NanoTestRunner;
import shohei909.nanotest.NanoTestCase;

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
	}
}