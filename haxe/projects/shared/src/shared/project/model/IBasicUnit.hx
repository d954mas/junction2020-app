package shared.project.model;
import shared.project.storage.Storage.LevelRoadPart;
interface IBasicUnit {
    function getPos():LevelRoadPart;
    function canMove():Bool;
    function move(roadPartIdx:Int):Void;
    function getOwnerId():Int;
    function getId():Int;
}
