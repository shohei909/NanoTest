package nanotest;

typedef NanoTestResult = {
	className : String, 
	method : String, 
	testCase : NanoTestCase,
	async : Bool,
	error : Bool,
	failed : Bool,
	status : Array<NanoTestStatus>,
}