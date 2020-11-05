var LibDebugGame= {


	HtmlDebugGameShowLogs: function(show){
		//console.log("debug logs:" + show);
		//console.log("debug logs:" + typeof show);

		window.debug_game.show_logs(show===1);
	},
}

mergeInto(LibraryManager.library, LibDebugGame);