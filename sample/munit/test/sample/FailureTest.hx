package sample;
import massive.munit.Assert;

/**
 * ...
 * @author shohei909
 */
class FailureTest
{
	@Test
	public function failureTest()
	{
        Assert.areEqual( 5, 2 + 2 );
	}

	@Test
	public function errorTest()
	{
		throw "error test";
	}
}
