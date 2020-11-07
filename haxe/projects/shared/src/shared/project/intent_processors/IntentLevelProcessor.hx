package shared.project.intent_processors;
import shared.base.event.ModelEventName.EventHelper;
import shared.project.configs.UnitConfig;
import shared.project.enums.UnitType;
import shared.base.enums.ContextName;
import shared.base.output.ModelOutputResultCode;
import shared.project.enums.Intent;
import shared.Shared.OutputResponce;

class IntentLevelProcessor extends IntentSubProcessor {

    public override function processIntent(intent:Intent, ?data:Dynamic):Null<OutputResponce> {
        var storage = world.storageGet();
        switch(intent){
            case Intent.LEVEL_SPAWN_UNIT:
                if (data == null) {throw "LEVEL_SPAWN_UNIT no data";}
                if (data.unit == null) {throw "LEVEL_SPAWN_UNIT no unit";}
                var unitType = UnitConfig.unitTypeGetById(data.unit);
                if (unitType == null) {throw "LEVEL_SPAWN_UNIT unknown unit";}
                var amount:Int;
                if (data.amount == null) {amount = 1;}
                else @:nullSafety(Off) amount = Std.parseInt(data.amount);

                var scales = UnitConfig.scalesByUnitType[unitType];
                if (scales == null) {throw "bad scales";}
                var price = world.levelModel.playerModel.unitGetPrice(unitType);
                var cost = amount * price;
                if (world.levelModel.playerModel.canSpendMoney(cost)) {
                    world.levelModel.playerModel.moneyChange(-cost, "spawn unit");
                    world.levelModel.playerModel.unitsSpawnUnit(unitType, amount);
                } else {
                    ask("not enought money.Need " + price);
                }


                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.LEVEL_CAST:
                if (data == null) {throw "LEVEL_CAST no data";}
                if (data.spell == null) {throw "LEVEL_CAST no spell";}
                var spelType = MageConfig.mageTypeGetById(data.spell);
                if (spelType == null) {throw "LEVEL_CAST unknown spell";}

                var scales = MageConfig.scalesByMageType[spelType];
                if (scales == null) {throw "bad scales";}
                var price = world.levelModel.playerModel.mageGetPrice(spelType);
                var cost = price;
                if (world.levelModel.playerModel.canSpendMana(cost)) {
                    world.levelModel.playerModel.manaChange(-cost, "cast");
                    world.levelModel.playerModel.castSpell(spelType);

                    //world.levelModel.playerModel.unitsSpawnUnit(unitType, amount);
                } else {
                    ask("not enought mana.Need " + price);
                }


                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.LEVEL_TURN_SKIP:
                ask("skip");
                EventHelper.levelTurnStart(world);
                world.levelModel.levelNextTurn();
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            case Intent.LEVEL_SPAWN_CARAVAN:
                ask("caravan");
                world.levelModel.playerModel.spawnCaravan();
                return baseProcessor.getResult({code : ModelOutputResultCode.SUCCESS});
            default: return null;
        }
        throw "no return for intent:" + intent;
    }

    private function checkCheats() {
        try {
            Assert.assert(world.isCheatsEnabled(), "cheats not enabled");
        } catch (e:Any) {
            world.contextDelete(ContextName.CHEATS);
            world.storageGet().profile.cheatsEnabled = false;
            throw e;
        }
    }
}
