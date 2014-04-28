package sample;
import nanotest.NanoTestRunner;
import nanotest.NanoTestCase;
 
class TestSample {   
    static public function main(){
        var r = new NanoTestRunner();
        r.add(new TestSampleCase());
        r.run();
    }
}
 
class TestSampleCase extends NanoTestCase {
    public function testBasic(){
        assertEquals( "A", "A" );
    }
}