package shohei909.nanotest;

typedef NanoTestResult = {
	className : String, 
	method : String, 
	testCase : NanoTestCase,
	error : Bool,
	failed : Bool,
	status : Array<NanoTestStatus>,
}