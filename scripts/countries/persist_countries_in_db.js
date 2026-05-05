import { createClient } from '@supabase/supabase-js'
import { loadEnvFile } from 'node:process';
loadEnvFile('../.env');
const supabase = createClient(process.env.CLIENT_URL, process.env.SERVICE_ROLE)

// countries_table_api = `${process.env.CLIENT_URL}/countries_data`
const DEBUG=false

const result = await fetch(`https://restcountries.com/v3.1/${DEBUG ? "name/france" : "all"}?fields=area,borders,name,cca3,idd,capital,translations,flags,tld,unMember`);
let json = await result.json();
if (DEBUG) {
    json = json.splice(0, 5);
}

const countriesList = [];

for (let i = 0; i < json.length; i++) {
    const rawTrans = new Map(Object.entries(json[i]["translations"]));
    const filteredMap = {};
    rawTrans.forEach((val, key) => {
        filteredMap[key] = val["common"];
    });
    
    const country = {
        flagLink: json[i]["flags"]["png"],
        countryName: json[i]["name"]["common"],
        internetExtensions: json[i]["tld"],
        cca3: json[i]["cca3"].toUpperCase(),
        unMember: json[i]["unMember"],
        capital: json[i]["capital"],
        borders: json[i]["borders"],
        area: json[i]["area"],
        iddRoot: json[i]["idd"]["root"],
        iddSuffixes: json[i]["idd"]["suffixes"],
        translations: filteredMap,
    }

    countriesList.push(country);
}

const { data, error } = await supabase.from('countries_data').insert(countriesList);
console.log({
    data: data,
    error: error,
});
