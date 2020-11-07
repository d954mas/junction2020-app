package shared.project.model;
import shared.project.storage.Storage.LevelRoadPart;
interface IBattleUnit {
    function attack(enemy:IBattleUnit):Void;
    function canAttack(enemy:IBattleUnit):Bool;
    function takeDamage(amount:Int):Void;
    function isAlive():Bool;
    function getPos():LevelRoadPart;
    function canMove():Bool;
    function move(roadPartIdx:Int):Void;
    function getOwnerId():Int;
    function getHp():Int;
    function getId():Int;
}
