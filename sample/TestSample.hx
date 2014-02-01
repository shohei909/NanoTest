package sample;
import shohei909.nanotest.NanoTestRunner;
import shohei909.nanotest.NanoTestCase;
 
class TestSample {   
    static function main(){
        var r = new NanoTestRunner();
        r.add(new SampleCase());
        r.run();
    }
}
 
class SampleCase extends NanoTestCase {
    public function testBasic(){
        assertEquals( "A", "A" );
    }   
}