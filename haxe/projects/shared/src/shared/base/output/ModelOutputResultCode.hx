package shared.base.output;


enum abstract ModelOutputResultCode(String) {
    var SUCCESS = "SUCCESS";
    var EXIT = "EXIT";
    var EXIT_AND_SAVE = "EXIT_AND_SAVE";
    var FAIL = "FAIL";
    var ERROR = "ERROR";


}
