/**
 * @license
 * Copyright Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// [START sheets_quickstart]
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

async function update_words(sheets,auth,table, sheet_name, data){
	await gdoc.clear(sheets, auth, table, sheet_name + "!A2:K");
	let wordDataTitle = ["word", "chars", "length", "points", "is_swear", "frequency_gbooks", "frequency_web", "frequency_avg"];
	await gdoc.addRows(sheets, table, sheet_name +"!A2:K", [wordDataTitle]);

	let wordData = require(data);
	let wordRows = [];
	for (const [key, value] of Object.entries(wordData)) {
		let row = []
		wordDataTitle.forEach(function (item, index) {
			row.push(value[item]);
		});
		wordRows.push(row);
	}
	await gdoc.addRows(sheets, table, sheet_name + "!A3:K", wordRows);
}

async function update_words_can_made(sheets,auth,table, sheet_name,start_part,end_part,part_name){
	await gdoc.clear(sheets, auth, table, sheet_name+"!A3:G");
	await gdoc.clear(sheets, auth, table, sheet_name +"!H3:Z");
	let wordCanMadeDataTitle = ["chars", "length", "pointsMax", "base_words", "All", "Popular", "Normal", "Bad"
		, "All", "Popular", "Normal", "Bad", "All", "Popular", "Normal", "Bad", "All", "Popular", "Normal", "Bad",
		"sigma","quantity scores", "scores", "totalComplexity"];
	await gdoc.addRows(sheets, table, sheet_name + "!A3:Z", [wordCanMadeDataTitle]);
	let parts = end_part;
	let startRange = 4;
	let wordRows = [];
	for (let i = start_part; i <= parts; i++) {
		console.log("file:" + part_name + i + ".json");
		let data = require(part_name + i + ".json");
		for (const [key, value] of Object.entries(data)) {
			let row = [];
			row.push(key);
			row.push(value.length);
			row.push(value.pointsMax);
			row.push(JSON.stringify(value.base_words));

			row.push(value.countWordsAll);
			row.push(value.countWordsPopular);
			row.push(value.countWordsNormal);
			row.push(value.countWordsBad);

			row.push(value.pointsPercentil25All);
			row.push(value.pointsPercentil25Popular);
			row.push(value.pointsPercentil25Normal);
			row.push(value.pointsPercentil25Bad);

			row.push(value.pointsPercentil50All);
			row.push(value.pointsPercentil50Popular);
			row.push(value.pointsPercentil50Normal);
			row.push(value.pointsPercentil50Bad);

			row.push(value.pointsPercentil75All);
			row.push(value.pointsPercentil75Popular);
			row.push(value.pointsPercentil75Normal);
			row.push(value.pointsPercentil75Bad);

			row.push(value.sigma);
			row.push(value.quantityScores);
			row.push(value.scores);

			row.push(value.totalComplexity);


			//row.push(JSON.stringify(value.words))
			wordRows.push(row);
			if (wordRows.length == 10000) {
				await gdoc.addRows(sheets, table, sheet_name+"!A" + startRange + ":Z", wordRows);
				startRange += wordRows.length;
				wordRows = [];
				await new Promise(resolve => setTimeout(resolve, 1000));
			}
		}
	}
	if (wordRows.length != 0) {
		await gdoc.addRows(sheets, table, sheet_name+"!A" + startRange + ":Z", wordRows);
		startRange += wordRows.length;
		wordRows = [];
	}
}

async function main(auth) {
    console.log("start");
    const sheets = google.sheets({version: 'v4', auth});
    const WORDS_TABLE = "1oLDTOpn4W-I7TN_bLXBkiIkngvgAwZIkj8pZHmaymCY"
    const WORDS_TABLE_RU = "11gyjepuDNdDANNuZhNmSOihpDIhKIja7I7MyWnSeMl0"
    const WORDS_TABLE_RU_2 = "1g_IlVCgyotH92TISTDnYbfijzHfIik1VNEGqZ0Lgdz0"
	
    const WORDS_TABLE_RU_CAN_MADE = "1p9bFxGdh-yYKz9kEPdcVEEwxF32pFRhHlRhDaddUnrk"
    const WORDS_TABLE_RU_CAN_MADE_2 = "13npmKR8KeI38lOQMhH2j0IbZivBbz1zWIiKzMDO34Rw"
    const WORDS_TABLE_RU_CAN_MADE_3 = "1T2lVZrtgYMijarkysGdptJrqZQzbstI4fqd49Ls2N2U"
    const WORDS_TABLE_RU_CAN_MADE_4 = "1SOSd4rMof6vEJVKIyuHPbxvI6QdtQ-Z3T6uLZfxp5aM"
    const WORDS_TABLE_RU_CAN_MADE_5 = "1-SGI7Nf0cKcPrxA2zZ4Fp72g2RHRAPRF2_HxerTGX1U"

    let UPDATE_WORDS = true;
	let UPDATE_WORDS_CAN_MADE = true;
	 
    let UPDATE_WORDS_RU = true;
	let UPDATE_WORDS_CAN_MADE_RU = true;
   

    //words sheet
    if (UPDATE_WORDS) {
        console.log("words sheet")
        await update_words(sheets,auth,WORDS_TABLE,"words","../../data/words_db_1.json");
    }
	if(UPDATE_WORDS_RU){
		console.log("words sheet ru")
		await update_words(sheets,auth,WORDS_TABLE_RU,"words","../../data/words_db_ru_1.json");
		//await update_words(sheets,auth,WORDS_TABLE_RU,"words_2","../../data/words_db_ru_2.json");
		//await update_words(sheets,auth,WORDS_TABLE_RU_2,"words_3","../../data/words_db_ru_3.json");
		//await update_words(sheets,auth,WORDS_TABLE_RU_2,"words_4","../../data/words_db_ru_4.json");
	}

    //words_can_made sheet
    if (UPDATE_WORDS_CAN_MADE) {
        console.log("words_can_made sheet")
		await update_words_can_made(sheets, auth, WORDS_TABLE, "words_can_made",1,100,"../../data/words_can_made_db/words_can_made_db_");
    }
	
	 if (UPDATE_WORDS_CAN_MADE_RU) {
        console.log("words_can_made sheet")
		await update_words_can_made(sheets, auth, WORDS_TABLE_RU_CAN_MADE, "words_can_made",1,200,"../../data/words_can_made_db_ru/words_can_made_db_");
		//await update_words_can_made(sheets, auth, WORDS_TABLE_RU_CAN_MADE_2, //"words_can_made",41,81,"../../data/words_can_made_db_ru/words_can_made_db_");
	//	await update_words_can_made(sheets, auth, WORDS_TABLE_RU_CAN_MADE_3, //"words_can_made",82,123,"../../data/words_can_made_db_ru/words_can_made_db_");
	//	await update_words_can_made(sheets, auth, WORDS_TABLE_RU_CAN_MADE_4, //"words_can_made",124,164,"../../data/words_can_made_db_ru/words_can_made_db_");
	//	await update_words_can_made(sheets, auth, WORDS_TABLE_RU_CAN_MADE_5, //"words_can_made",165,200,"../../data/words_can_made_db_ru/words_can_made_db_");
  
    }

    console.log("finish");

}