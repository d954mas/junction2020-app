package shared.project.timers;
import shared.project.model.World;
import shared.project.storage.Storage.TimerStorageStruct;

enum abstract TimerStatus(String) {
    var WORK = "WORK";
    var PAUSED = "PAUSED";

}

class BaseTimer {
    private var world:World;
    private var timerStruct:TimerStorageStruct;

    public function new(world:World, timerStruct:TimerStorageStruct) {
        this.world = world;
        this.timerStruct = timerStruct;
    }

    public function valueGetMax():Int {
        return 0;
    }

    public function timerGetCurrentTime():Float {
        return world.storageGet().timers.time;
    }

    public function valueGetCurrent():Int {
        return 0;
    }

    public function valueSet(value:Int) {
    }

    public function restoreValueGet():Int {
        return 1;
    }

    public function delayGet():Int {
        return 0;
    }


    public function getTimerStruct():TimerStorageStruct {
        return timerStruct;
    }

    public function getTimerDelta():Float{
        return world.storageGet().timers.timerDelta;
    }
    ///@param firstTime первый раз в этом запросе/кадре.Нужно для правильной работы паузы
    public function update(firstTime:Bool = false) {
        var current:Int = valueGetCurrent();
        var max:Int = valueGetMax();
        //timer done
        if (current >= max) {
            timerStruct.endTime = -1;
            timerStruct.startTime = -1;
            timerStruct.timeLeft = 0;
        } else {
            if (timerStruct.endTime == -1 || timerStruct.startTime == -1) {
                //start timer
                timerStruct.startTime = timerGetCurrentTime();
                timerStruct.endTime = timerStruct.startTime + delayGet();
                timerStruct.timeLeft = delayGet();
            } else {

            }
            //Таймеры привязаны к реальному времени. Чтобы пауза работала, сдвигаю время окончания
            if (firstTime && timerStruct.status == TimerStatus.PAUSED) {
                if (timerStruct.endTime != -1) {
                    timerStruct.endTime += getTimerDelta();
                }
            }
            if (timerStruct.status == TimerStatus.WORK) {
                if (timerGetCurrentTime() >= timerStruct.endTime) {
                    timerStruct.startTime = timerStruct.endTime;
                    timerStruct.endTime = timerStruct.startTime + delayGet();
                    valueSet(current + restoreValueGet());
                    update();//check again.Mb need stop or restore more that one time
                }
            }

            timerStruct.timeLeft = cast Math.max(timerStruct.endTime - timerGetCurrentTime(), 0);
        }


    }
}
