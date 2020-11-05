const fs = require('fs');
const readline = require('readline');
const {google} = require('googleapis');
const zlib = require('zlib');
const gdoc = require("./gdoc");


// Load client secrets from a local file.
fs.readFile('credentials.json', (err, content) => {
    if (err) return console.log('Error loading client secret file:', err);
    // Authorize a client with credentials, then call the Google Sheets API.
    gdoc.authorize(JSON.parse(content), main);
});

const MAX_REGION = 2

async function download_heroes(sheets,auth,table, sheet_name){
	let result = {
	
	}
	let rows = await gdoc.get(sheets,auth,table, sheet_name +"!A3:P1000");
	console.log("download " + table);
	
	let idx = 0;
	let currentHero = "";
	while(idx < rows.length){
		let row = rows[idx];
		if(row[0]){
			currentHero = row[0];
			if(result[currentHero]){throw "hero:" + currentHero + " already exist. row:" + row;}
			console.log("hero:" + currentHero);
			result[currentHero] = {
				awaikenCost:0,
				//в доке нумерация с 1 а в уровнях с 0
				openAfterLevel: parseInt(row[8])-1,
				levels:[{profileLevel:0, cost:0, hp:0, attackMultiply:0}]//0 not used
			}
		}
		//parse level
		else{
			let levelIdx = row[2];
			console.log(levelIdx);
			if(levelIdx == 1){
				let awaikenCost=parseInt(row[5]);
				if(awaikenCost === null){throw "no awaiken cost:" + row;}
				result[currentHero].awaikenCost = awaikenCost;
			}
			if(result[currentHero].levels.length != levelIdx){throw "bad level.Get:" + levelIdx + " need:" + (result[currentHero].levels.length);}
			let level = {profileLevel:parseInt(row[3]), cost:parseInt(row[4]), hp:parseInt(row[6]), attackMultiply:parseFloatMy(row[7])}
			result[currentHero].levels.push(level);
		}
		idx++;
	}
	return result;

}

async function download_enemies(sheets,auth,table, sheet_name){
	let result = {}
	let rows = await gdoc.get(sheets,auth,table, sheet_name +"!A3:P1000");
	console.log("download " + table);
	
	let idx = 0;
	let currentEnemy = "";
	while(idx < rows.length){
		let row = rows[idx];
		if(row[0]){
			currentEnemy = row[0];
			if(result[currentEnemy]){throw "enemy:" + currentEnemy + " already exist. row:" + row;}
			console.log("enemy:" + currentEnemy);
			result[currentEnemy] = {
				levels:[{ hp:0, attack:0}]//0 not used
			}
		}
		//parse level
		else{
			let levelIdx = row[2];
			if(levelIdx){
				console.log(levelIdx);
				if(result[currentEnemy].levels.length != levelIdx){throw "bad level.Get:" + levelIdx + " need:" + (result[currentEnemy].levels.length);}
				let level = {hp:parseInt(row[3]), attack:parseInt(row[4])}
				result[currentEnemy].levels.push(level);
			}
			
		}
		idx++;
	}
	return result;

}

async function download_profile_levels(sheets,auth,table, sheet_name){
	let result = []
	let rows = await gdoc.get(sheets,auth,table, sheet_name +"!A3:P1000");
	console.log("download " + table);
	let idx = 0;
	while(idx < rows.length){
		let row = rows[idx];
		let levelIdx = row[0];
		if(levelIdx){
			levelIdx = parseInt(levelIdx);
			console.log(levelIdx);
			if(result.length+1 != levelIdx){throw "bad level.Get:" + levelIdx + " need:" + (result.length+1);}
			result.push({exp:parseInt(row[2]),money:parseInt(row[3]),leafs:parseInt(row[4]),
				booster_x2:parseInt(row[5]), booster_any_char:parseInt(row[6]), booster_tooltip:parseInt(row[7])});
		}
		idx++;
	}
	return result;
}

function parseFloatMy(v){
	return parseFloat(v.replace(/,/, '.'));
}

async function download_regions(sheets,auth,table, sheet_name){
	let result = []
	let rows = await gdoc.get(sheets,auth,table, sheet_name +"!A5:AH1000");
	console.log("download " + table);
	
	let idx = 0;
	let currentRegion = 0;
	while(idx < rows.length){
		let row = rows[idx];
		if(row[0]){
			currentRegion = parseInt(row[0]);
			if(result.length+1 != currentRegion){throw "bad region.Get:" + currentRegion + " need:" + (result.length+1);}
			console.log("region:" + currentRegion);
			if(currentRegion >MAX_REGION){
			    break;
			}
			let region = {levels:[],finalLevelStars:parseInt(row[2]),restricts:{}};
			result.push(region);
			let warrior = parseInt(row[3]);
			let shaman = parseInt(row[4]);
			let ranger = parseInt(row[5]);
			if(warrior != 0){region.restricts.WARRIOR = warrior;}
			if(shaman != 0){region.restricts.SHAMAN = shaman;}
			if(ranger != 0){region.restricts.RANGER = warrior;}
			let level = null;
			for (var m in region.restricts){
				console.log(m);
				if(level === null){level = region.restricts[m]}
				if(region.restricts[m]!==level){
					throw "level should be same.("+level + "/" +  region.restricts[m] + ")";
				}
			}
				
		}
		//parse level
		else{
			let region = result[currentRegion-1];
			if(!region){throw "no region:" + currentRegion;}
			let levelIdx = row[6];
			if(levelIdx){
				console.log("level:" + levelIdx);

				if(region.levels.length+1 != levelIdx){throw "bad level.Get:" + levelIdx + " need:" + (result.levels.length+1);}
				let level = {enemy:row[7], enemyLevel:parseInt(row[8]),hpMul:parseFloatMy(row[9]),attackMul:parseFloatMy(row[10]), timer:parseInt(row[11]),
					words:row[12],wordsConfig:{lenMin:parseInt(row[13]),lenMax:parseInt(row[14]),diffMin:parseFloatMy(row[15]),diffMax:parseFloatMy(row[16])},
					mixWord:row[17]=="TRUE",rewards:[],changeWord:false,changeWordTimer:0};
					
				if(level.wordsConfig.lenMin == null || typeof(level.wordsConfig.lenMin) === "undefined" || isNaN(level.wordsConfig.lenMin)){
					level.wordsConfig = null;
				}
				if(level.words === ""){
					level.words = null;
				}
				level.rewards[0] = {gold:parseInt(row[18]),leafs:parseInt(row[19]),exp:parseInt(row[20])}
				level.rewards[1] = {gold:parseInt(row[18+3]),leafs:parseInt(row[19+3]),exp:parseInt(row[20+3])}
				level.rewards[2] = {gold:parseInt(row[18+3*2]),leafs:parseInt(row[19+3*2]),exp:parseInt(row[20+3*2])}
				level.rewards[3] = {gold:parseInt(row[18+3*3]),leafs:parseInt(row[19+3*3]),exp:parseInt(row[20+3*3])}
				
				var changeWord = row[30];
				var changeWordTimer = row[31];
				
				if(changeWord === "TRUE"){
					changeWord = true
					changeWordTimer = parseInt(changeWordTimer)
					if(changeWordTimer<=0){
							throw "bad changeWordTimer value:" + changeWordTimer
					}
					if(level.wordsConfig.lenMin!==level.wordsConfig.lenMax){
							throw "change word should have same size. Min:" + level.wordsConfig.lenMin + " Max:" + level.wordsConfig.lenMax
					}
				}else{
					changeWord = false
					changeWordTimer = 0
				}
				level.changeWord = changeWord;
				level.changeWordTimer = changeWordTimer;
				
				var treasure = row[32];
				var treasureConfig = row[33];
				if(treasure === "TRUE"){
					treasureConfig = JSON.parse(treasureConfig)
					console.assert(treasureConfig.gold || treasureConfig.leafs)
					if(treasureConfig.gold){
						console.assert(treasureConfig.gold.chance > 0);
						console.assert(treasureConfig.gold.turnsMin >= 1);
						console.assert(treasureConfig.gold.turnsMax >= treasureConfig.gold.turnsMin);
					}
					if(treasureConfig.leafs){
						console.assert(treasureConfig.leafs.chance > 0);
						console.assert(treasureConfig.leafs.turnsMin >= 1);
						console.assert(treasureConfig.leafs.turnsMax >= treasureConfig.leafs.turnsMin);
					}
					level.treasure = true
					level.treasureConfig = treasureConfig
				}else{
					level.treasure = false
				}
				
				
				region.levels.push(level);
			}
			
		}
		idx++;
	}
	return result;
}

async function download_config(sheets,auth,path){
	let heroes = await download_heroes(sheets,auth,path,"heroes");
	let enemies = await download_enemies(sheets,auth,path,"enemies");
	let profile = await download_profile_levels(sheets,auth,path,"profile");
	let regions = await download_regions(sheets,auth,path,"regions");
	
	let result = {
		heroes:heroes,
		enemies:enemies,
		profileLevels:profile,
		regions:regions
	}
	return result
}

async function main(auth) {
    console.log("start");
    const sheets = google.sheets({version: 'v4', auth});
    const config_en = "1znO7Nr5Kk9xwrsGSu9rXJzROHc-Xsv4gs2GAy48FYgI"
    const config_ru = "1pS5gi02LFs_VX6UmALl4bphDgogIi5sy_OSQf8-TWyE"
	
	
	console.log("load EN");	
	fs.writeFile("./configs/configs_en.json", JSON.stringify({}, null, "\t"), (err) => {
		if (err) return console.error(err);
		console.log("EN saved");
	});
	
		console.log("load RU");
	fs.writeFile("./configs/configs_ru.json", JSON.stringify({}, null, "\t"), (err) => {
		if (err) return console.error(err);
		console.log("RU saved");
	});
	
    console.log("finish");

}