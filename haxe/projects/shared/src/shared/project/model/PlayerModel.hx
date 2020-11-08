package shared.project.model;
import shared.project.configs.UnitConfig;
import shared.project.enums.UnitType;
import shared.project.configs.GameConfig;
import Array;
import shared.base.event.ModelEventName.EventHelper;
import shared.project.enums.GameEnums.RoadType;
import shared.project.storage.Storage.LevelPlayerStruct;
import shared.project.storage.Storage.LevelStruct;
import shared.project.storage.Storage;

@:expose @:keep
class PlayerModel {
    private var world:World;
    private var ds:StorageStruct;

    public function new(world:World) {
        this.world = world;
        this.ds = this.world.storageGet();
        modelRestore();
    }

    @:nullSafety(Off)
    public function spawnCaravan():Bool {
        if (ds.level.caravans.length < caravanGetMax()) {
            EventHelper.levelTurnStart(world);
        }
        var success = world.levelModel.spawnCaravan(ds.level.player.caravanLevel);
        if (success) {
            world.speechBuilder.text("spawned caravan");
            world.levelModel.levelNextTurn();
        }
        return success;
    }

    public function unitsSpawnUnit(unitType:UnitType, amount:Int) {
        EventHelper.levelTurnStart(world);
        world.levelModel.enqueueUnits(0, unitType, amount);
        world.speechBuilder.text("enqueued " + unitType);
        //spawn это ход игрока

        world.levelModel.levelNextTurn();
    }

    public function modelRestore():Void {

    }

    //tag for visual. To understand how to show
    public function moneyChange(value:Int, tag:String) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:moneyChange";}
        if (value == 0) {return;}
        if (level.player.money + value < 0) {throw "not enought money";}

        level.player.money += value;
        EventHelper.levelMoneyChange(world, value, tag);
    }

    public function canSpendMoney(value:Int) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:moneyChange";}
        return (level.player.money >= value);
    }

    @:nullSafety(Off)
    public function castSpell(type:MageType, newTurn:Bool) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for castSpell";}
        if (newTurn) {EventHelper.levelTurnStart(world);}

        EventHelper.levelCastSpellStart(world, type);
        var power = mageGetPower(type);
        if (type == MageType.FIREBALL) {
            for (unit in world.levelModel.battleUnitModels) {
                if (unit.getOwnerId() > 0 && unit.getType() != UnitType.CASTLE) {
                    unit.takeDamage(power);
                    EventHelper.levelUnitAttack(world, -10000, unit.getId());
                }
            }
            world.levelModel.removeDeadUnits();
        } else if (type == MageType.ICE) {
            level.ice = power;
            if(newTurn){
                level.ice++;
            }
            world.levelModel.removeDeadUnits();
        } else if (type == MageType.CARAVAN) {
            level.mageLevels.set(Std.string(MageType.CARAVAN), level.mageLevels.get(Std.string(MageType.CARAVAN)) + 1);
        } else if (type == MageType.MANA) {
            level.mageLevels.set(Std.string(MageType.MANA), level.mageLevels.get(Std.string(MageType.MANA)) + 1);
        }
        EventHelper.levelCastSpellEnd(world, type);

        if (newTurn) {world.levelModel.levelNextTurn();};
    }

    public function canSpendMana(value:Int) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:moneyChange";}
        return (level.player.mana >= value);
    }

    public function unitGetPrice(type:UnitType) {
        var scales = UnitConfig.scalesByUnitType[type];
        if (scales == null) {throw "bad scales";}
        var price = scales.costByLevel[0];
        return price;
    }

    @:nullSafety(Off)
    public function mageGetPrice(type:MageType) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:mageGetPrice";}
        var mageLevel = level.mageLevels.get(Std.string(type));
        var scales = MageConfig.scalesByMageType[type];
        if (scales == null) {throw "bad scales";}
        var price = scales.costByLevel[mageLevel];
        return price;
    }

    @:nullSafety(Off)
    public function mageGetPower(type:MageType) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:mageGetPrice";}
        var mageLevel = level.mageLevels.get(Std.string(type));
        var scales = MageConfig.scalesByMageType[type];
        if (scales == null) {throw "bad scales";}
        var price = scales.powerByLevel[mageLevel];
        return price;
    }

    @:nullSafety(Off)
    public function mageGetPower2(type:MageType) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:mageGetPrice";}
        var mageLevel = level.mageLevels.get(Std.string(type));
        var scales = MageConfig.scalesByMageType[type];
        if (scales == null) {throw "bad scales";}
        var price = scales.power2ByLevel[mageLevel];
        return price;
    }

    public function mageGetMaxMana() {
        return mageGetPower2(MageType.MANA);
    }

    public function caravanGetMax() {
        return mageGetPower(MageType.CARAVAN);
    }

    public function mageGetManaRegen() {
        return mageGetPower(MageType.MANA);
    }


    public function manaChange(value:Int, tag:String) {
        var level = world.storageGet().level;
        if (level == null) {throw "no level model for playerModel:manaChange";}
        if (value == 0) {return;}
        if (level.player.mana + value < 0) {throw "not enought mana";}
        if (level.player.mana + value > mageGetMaxMana()) {
            value = mageGetMaxMana() - level.player.mana;
        }
        if (value == 0) {return;}
        level.player.mana += value;
        EventHelper.levelManaChange(world, value, tag);
    }


}
