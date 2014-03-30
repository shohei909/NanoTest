package nanotest;
import haxe.CallStack.StackItem;
import haxe.PosInfos;

enum NanoTestStatus{
	SUCCESS( posInfos:PosInfos );
	FAIL( message:String, posInfos:PosInfos );
	ERROR( message:String, callStack:Array<StackItem> );
}