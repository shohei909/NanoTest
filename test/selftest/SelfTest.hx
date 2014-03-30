package selftest;

import selftest.cases.SelfTestCase;
import nanotest.NanoTestRunner;

/**
 * ...
 * @author shohei909
 */

class SelfTest {
	static public function main() {
		var runner = new NanoTestRunner();
		runner.add( new SelfTestCase() );
		runner.run();
	}
}