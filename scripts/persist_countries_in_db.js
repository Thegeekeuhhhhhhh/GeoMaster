import { createClient } from '@supabase/supabase-js'
import { loadEnvFile } from 'node:process';
loadEnvFile('.env');
const supabase = createClient(process.env.CLIENT_URL, process.env.SUPABASE_PUBLIC_KEY)

// countries_table_api = `${process.env.CLIENT_URL}/countries_data`
const DEBUG=true

const result = await fetch(`https://restcountries.com/v3.1/${DEBUG ? "name/france" : "all"}?fields=area,borders,name,cca3,idd,capital,translations,flags,tld,unMember`);
const json = await result.json();

for (let i = 0; i < json.length; i++) {
    const rawTrans = new Map(Object.entries(json[i]['translations']));
    const country = {
        flagLink: json[i]["flags"]["png"],
        countryName: json[i]["name"]["common"],
        internetExtensions: json[i]["tld"],
        cca3: json[i]["cca3"].toUpperCase(),
        unMember: json[i]["unMember"],
        capital: json[i]["capital"],
        borders: json[i]["borders"],
        area: json[i]["area"],
        idd: json[i]["idd"],
        translations: rawTrans,
    }
    
    const { data, error } = await supabase.from('countries_data').insert(country);
    console.log(data);
    console.log(error);
}
