package ;
import shared.project.tutorial.tutorials.TutorialBase;
import shared.Shared;
import utest.Assert;
class TutorialTest extends BaseTest {

    function testNoTutorialWithSameID() {
        var shared:Shared = Utils.prepareNewUser(conv);
        var tutorialsOrder:Array<TutorialBase> = Reflect.field(shared.world.tutorialsModel, "tutorialsOrder");
        var names:Map<String, Bool> = new Map();
        for (tutorial in tutorialsOrder) {
            var def:TutorialTypedef = Reflect.field(tutorial, "def");
            Assert.isFalse(names.exists(def.id), "id:" + def.id + "already exist");
            names.set(def.id, true);
        }
    }

}
