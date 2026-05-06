import { createClient } from '@supabase/supabase-js'
import { loadEnvFile } from 'node:process';
loadEnvFile('../.env');
const supabase = createClient(process.env.CLIENT_URL, process.env.SERVICE_ROLE)

const DEBUG=false
const DEBUG2=false
const BATCH_SIZE = 40;

const result = await fetch(`https://restcountries.com/v3.1/${DEBUG ? "name/france" : "all"}?fields=cca3,coatOfArms,currencies,languages,population`);
let json = await result.json();
if (DEBUG2) {
    json = json.splice(0, 5);
}

const promises = [];

for (let i = 0; i < json.length; i++) {
    const country = {
        emblemLink: json[i]["coatOfArms"]["png"],
        currencies: Object.keys(json[i]["currencies"]),
        languages: Object.keys(json[i]["languages"]),
        population: json[i]["population"],
    };

    promises.push(() => supabase.from('countries_data').update(country).eq("cca3", json[i]["cca3"]).then(({data, error}) => {
        if (error) {
            console.log({
                data: data,
                error: error,
            });
        }
    }));
}

for (let i = 0; i < promises.length; i += BATCH_SIZE) {
    const batch = promises.slice(i, i + BATCH_SIZE).map(f => f());
    await Promise.all(batch);
    console.log(`BATCH n.${i / BATCH_SIZE + 1} done`);
}
