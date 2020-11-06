package shared.project.model;
import shared.project.storage.Storage.LevelRoadPart;
interface IBattleUnit {
    function attack(enemy:IBattleUnit):Void;
    function canAttack(enemy:IBattleUnit):Bool;
    function takeDamage(amount:Int):Void;
    function isAlive():Bool;
    function getPos():LevelRoadPart;
    function canMove():Bool;
    function move(newPost:LevelRoadPart):Void;
    function getOwnerId():Int;
}
