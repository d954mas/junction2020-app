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

async function download_localization(sheets,auth,table, sheet_name){
	let result = {
		ru:{},
		en:{},
	}
	console.log("download " + table);
	let rows = await gdoc.get(sheets,auth,table, sheet_name +"!A2:D1000");;
	rows.map((row) => {
		let key = row[0];
		if(key){
			let en = row[2];
			let ru = row[3];
			if(result.ru[key]){throw "key already exist:" + key;}
			if(result.en[key]){throw "key already exist:" + key;}
			result.ru[key] = ru;
			result.en[key] = en;
		}
	});
	return result;

}

async function download_localization_speech_commands(sheets,auth,table, sheet_name){
	let result = {
		ru:{},
		en:{},
	}
	console.log("download " + table);
	let rows = await gdoc.get(sheets,auth,table, sheet_name +"!A3:E1000");;
	rows.map((row) => {
		let key = row[0];
		if(key){
			let order = parseInt(row[2]);
			let en = row[3];
			let ru = row[4];
			if(result.ru[key]){throw "key already exist:" + key;}
			if(result.en[key]){throw "key already exist:" + key;}
			result.ru[key] = {order:order, text:ru};
			result.en[key] = {order:order, text:en};
		}
	});
	return result;
}

async function download_localization_match_words(sheets,auth,table, sheet_name){
	let result = {
		ru:{},
		en:{},
	}
	console.log("download " + table);
	let rows = await gdoc.get(sheets,auth,table, sheet_name +"!A3:G1000");
	rows.map((row) => {
			let key = row[0];
			if(key){
				let en = row[5];
				let ru = row[6];
				if(en){
					result.en[key] = JSON.parse(en)
				}
				if(ru){
					result.ru[key] = JSON.parse(ru)
				}
			}
		
	});
	return result;

}


async function main(auth) {
    console.log("start");
    const sheets = google.sheets({version: 'v4', auth});
    const LOCALIZATION = "1FsZXDjXvgHK29QxOlBYz6Q3Q_Nb85Goz3k_BeR98Mb0"
	let locale_ru = {
		client:{},
		conv:{},
		tutorial:{}
	}
	
	let locale_en = {
		client:{},
		conv:{},
		tutorial:{}
	}
	let conv = await download_localization(sheets,auth,LOCALIZATION,"conv");
	let client = await download_localization(sheets,auth,LOCALIZATION,"client");
	let tutorial = await download_localization(sheets,auth,LOCALIZATION,"tutorial");
	
	locale_en.conv = conv.en;
	locale_en.client = client.en;
	locale_en.tutorial = tutorial.en;
	
	locale_ru.conv = conv.ru;
	locale_ru.client = client.ru;
	locale_ru.tutorial = tutorial.ru;
	
	
	
	fs.writeFile("./localization/localization_en.json", JSON.stringify(locale_en, null, "\t"), (err) => {
		if (err) return console.error(err);
		console.log("save en");
	});
	
	fs.writeFile("./localization/localization_ru.json", JSON.stringify(locale_ru, null, "\t"), (err) => {
		if (err) return console.error(err);
		console.log("save ru");
	});
	
	let speechCommands = await download_localization_speech_commands(sheets,auth,LOCALIZATION,"speech commands");
	
	fs.writeFile("./localization/speech_commands_ru.json", JSON.stringify(speechCommands.ru, null, "\t"), (err) => {
		if (err) return console.error(err);
		console.log("save ru commands");
	});
	
	fs.writeFile("./localization/speech_commands_en.json", JSON.stringify(speechCommands.en, null, "\t"), (err) => {
		if (err) return console.error(err);
		console.log("save en commands");
	});
	
	let matchWords = await download_localization_match_words(sheets,auth,LOCALIZATION,"speech commands");
	
	fs.writeFile("./localization/match_words_ru.json", JSON.stringify(matchWords.ru, null, "\t"), (err) => {
		if (err) return console.error(err);
		console.log("save ru match words");
	});
	
	fs.writeFile("./localization/match_words_en.json", JSON.stringify(matchWords.en, null, "\t"), (err) => {
		if (err) return console.error(err);
		console.log("save en match words");
	});


    console.log("finish");

}