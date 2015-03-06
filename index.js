// Convert a DHCR Xcel file to a condensed CSV.
// Takes an xlsx file as `inFile` representing the DHCR's rent stabilized building list  
// and combines the xlsx sheets into an output csv as `outFile` with boro numbers

// modules
var fs = require('fs');
var xlsx = require('xlsx');
var xls = require('xlsjs');
var _ = require('underscore');
var parse = require('csv-parse');
var stringify = require('csv-stringify');

// variables in global scope
var inFile;
var outFile;
var workbook;
var sheets;
var worksheet_to_csv;
var allSheets = [];

// sheet names in DHCR xlsx files differ year to year. Some files have an 
// additional sheet that combines addresses for all 5 Boroughs but most do not.
var validSheetNames = [
  'Manhattan',
  'Manh',
  'Bronx',
  'Brooklyn',
  'Bklyn',
  'Queens',
  'Staten Isl',
  'Stat Isl',
  'SI' ];

function init() {
  // check for correct number of input parameters
  if (process.argv.length===4) {
    inFile = process.argv[2];
    outFile = process.argv[3];
    checkInFile(inFile);
  } else {
    console.log('script takes additional arguments for xlsx inFile and csv outFile');
    process.exit(1);
  }
}

function checkInFile(file){
  var ext = file.split('.').pop();
  console.log('inFile extsion: ', ext);
  if (ext==='xlsx') {
    parseXlsxSheets(file);
  } else if (ext==='xls') {
    parseXlsSheets(file);
  } else {
    console.log('inFile is not not a valid xcel file');
  }
}

function parseXlsxSheets(file) {
  workbook = xlsx.readFile(file);
  sheets = workbook.SheetNames;
  worksheet_to_csv = function(worksheet) {
    xlsx.utils.sheet_to_csv(worksheet);
  }; 
  parseSheets(sheets);
}

function parseXlsSheets(file){
  workbook = xls.readFile(file);
  sheets = workbook.SheetNames;
  worksheet_to_csv = function(worksheet) {
    return xls.utils.make_csv(worksheet);
  };
  parseSheets(sheets);
}

// iterate over csv representing a sheet. 
// Only write the header for the first sheet
function parseCSV(csv, boro, callback) {
  parse(csv, function(err, output){
    if (err) { console.log('parse csv error: ', err); }
    _.each(output, function(row, j){      
      if (boro===1 && j===0) {
        row.push('BORO_CODE');
        allSheets.push(row);      
      } else if (j>0) {
        row.push(boro);
        allSheets.push(row);
      }      
    });

    if (callback && typeof callback==="function") {
      callback();
    }
  });
}

// convert the parsed csv array back to a csv
function makeCSV(array) {  
  stringify(array, function(err, output) {
    if (err) { console.log('stringify array err: ', err); }
    writeCSV(outFile, output);
  });
}

// write the csv to an outfile
function writeCSV(filepath, data){
  fs.writeFile(filepath, data, function(err){
    if (err) {
      console.log('error: ', err);
    } else {
      console.log('file ', filepath, ' saved.');
    }
  });
}

// iterate over the xcel workbook's sheets
function parseSheets(sheets){
  sheets.forEach(function(y, i, sheets) {
    var idx = validSheetNames.indexOf(y);

    // make sure sheet name is valid
    if (idx >=0) {
      var worksheet = workbook.Sheets[y];
      var csv = worksheet_to_csv(worksheet);      
      // var csv = xlsx.utils.sheet_to_csv(worksheet);
      var boro;

      // store boro code based on sheet name
      if (y==="Brooklyn" || y === 'Bklyn') {
        boro = 3;
      } else if (y==="Queens") {
        boro = 4;
      } else if (y ==="Manhattan" || y === 'Manh') {
        boro = 1;
      } else if ( y==="Bronx" ) {
        boro = 2;
      } else if (y==="Staten Isl" || y === 'Stat Isl' || y==='SI') {
        boro = 5;
      } else {
        boro = 0;
      }

      // on the last sheet write the out file
      if (i === 4) {        
        parseCSV(csv, boro, function(){        
          console.log(allSheets.length);
          makeCSV(allSheets);
        });      
      } else {
        parseCSV(csv, boro, function(){
          console.log(allSheets.length);
        });
      }
    }
  });
}

// a simple way to convert all sheets as is to csv's. Not implemented here.
function to_csv(workbook) {
    var result = [];
      workbook.SheetNames.forEach(function(sheetName) {                
        var csv = xlsx.utils.sheet_to_csv(workbook.Sheets[sheetName]);
        if (csv.length > 0) {
            result.push(csv);
        }
    });
    return result.join("\n");
}

init();