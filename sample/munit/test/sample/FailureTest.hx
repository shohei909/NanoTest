package sample;
import massive.munit.Assert;

/**
 * ...
 * @author shohei909
 */
class FailureTest
{
	@Test
	public function mainTest() 
	{
		Assert.areEqual( 5, 2 + 2 );
	}
	
	@Test
	public function subTest() 
	{
		throw "error test";
	}
}