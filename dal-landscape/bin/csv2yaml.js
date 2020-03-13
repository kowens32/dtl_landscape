// NOTE:  Install Parser
//    npm install csv-parser@2.3.2
//   RUNAS :  node cvs2yaml.js ${PATH_TO_CSV_FILE} 
const csvParser = require('csv-parser');
const fs = require('fs');
const readline = require('readline');
const addPartnerCategory = true;
const addAPICategory = true;
const partnerFile = __dirname+"/../data/category-partners.yml";
const APILandscape = __dirname+"/../data/category-api.yml";

function checkArgs(args){

  if (args.length == 1){

    fs.access(args[0], fs.R_OK, (err) => {
      if (err) {
        console.error(err)
        console.error("Error: Argument must be a path to readable CSV file");
        console.error("         usage: node cvs2yaml.js ${PATH_TO_CSV_FILE} ")
        process.exit(1);
      }
    });

    return args[0];

  }
  console.error("Error: Argument must be one (and only one) path to readable CSV file");
  console.error("       usage: node cvs2yaml.js ${PATH_TO_CSV_FILE} ")
  process.exit(1);
}

function startReader(csvFile){

  var recentCategory="";
  var recentSubcategory="";
  var myheaders="";

  fs.createReadStream(csvFile)
    .on('error', () => {
        console.error("ERROR READING FILE!");
        return;
    })
    .pipe(csvParser())
    .on('headers', (headers) => {
        myheaders = headers;
    })
    .on('data', (row) => {

        // use row data
        let currentCategory = row[myheaders[0]];
        var currentSubcategory = row["SUBCATEGORY"];

        // Print Category Header if new
        if (currentCategory != recentCategory){
          recentCategory = currentCategory;
          console.log("  - category:");
          console.log("    name: " + currentCategory);
          console.log("    subcategories:");
        }
        
        // Print SubCategory Header if new
        if (currentSubcategory != recentSubcategory){
          recentSubcategory = currentSubcategory;
          console.log("      - subcategory:");
          console.log("        name: " + currentSubcategory);
          console.log("        items:");
        }
        
        //Print Item entries....
        console.log("          - item:");
        console.log("            name: "+row["NAME"]);
        console.log("            description: "+row["DESCRIPTION"]);
        console.log("            project: "+row["PROJECT"]);
        console.log("            delta_owner: "+row["DELTA_OWNER"]);
        console.log("            homepage_url: '"+row["HOMEPAGE_URL"]+"'");
        console.log("            stock_ticker: "+row["STOCK_TICKER"]);
        console.log("            open_source: "+row["OPEN_SOURCE"]);
        console.log("            twitter: '"+row["TWITTER"]+"'");
        console.log("            logo: "+row["LOGO"]);
        console.log("            crunchbase: '"+row["CRUNCHBASE"]+"'");

    })

    // {
    //   CATEGORY: 'Platform as a Service (PaaS)',
    //   SUBCATEGORY: 'PaaS Application Runtimes',
    //   NAME: 'NGINX',
    //   DESCRIPTION: 'Web server which can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache.',
    //   PROJECT: 'standard',
    //   DELTA_OWNER: 'Mauricio Lora',
    //   HOMEPAGE_URL: 'https://www.nginx.com/',
    //   STOCK_TICKER: '',
    //   LOGO: 'nginx.svg',
    //   OPEN_SOURCE: 'false',
    //   CRUNCHBASE: 'https://www.crunchbase.com/organization/nginx'
    // }

    .on('end', () => {

      if (addPartnerCategory){
        catCategoryFile(partnerFile);
      }
      
      if (addAPICategory){
        catCategoryFile(APILandscape);
      }
      
    })

}

function catCategoryFile(file_to_read){

  const rl = readline.createInterface({
    input: fs.createReadStream(file_to_read),
    crlfDelay: Infinity
  });

  rl.on('error', () => {
        console.error("ERROR READING PARTNERE FILE!");
        process.exit(1);

    }).on('line', function (line) {
      console.log(' ', line); // Need two whitespace for yml
    });
}


const csvFile = checkArgs(process.argv.slice(2));
console.log("landscape:");
startReader(csvFile);