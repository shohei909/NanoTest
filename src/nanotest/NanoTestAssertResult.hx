package nanotest;

/**
 * ...
 * @author shohei909
 */
class NanoTestAssertResult
{
	public var result(default, null):NanoTestResult;
	public var position(default, null):Int;
	
	public function new(_result:NanoTestResult, position:Int) {
		this.result = _result;
		this.position = position;
	}
	
	public function label(d:Dynamic) {
		switch (result.status[position]) {
			case SUCCESS(_) :
			case FAIL(mes, p) :
				result.status[position] = NanoTestStatus.FAIL('$mes [$d]', p);
			case ERROR(mes, p) :
				result.status[position] = NanoTestStatus.ERROR('$mes [$d]', p);
		}
		return this;
	}
}
