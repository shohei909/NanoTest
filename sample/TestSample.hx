package sample;
import shohei909.nanotest.NanoTestRunner;
import shohei909.nanotest.NanoTestCase;
 
class TestSample {   
    static function main(){
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