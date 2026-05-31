import { createClient } from '@supabase/supabase-js'
import { loadEnvFile } from 'node:process';
loadEnvFile('../.env');
const supabase = createClient(process.env.CLIENT_URL, process.env.SERVICE_ROLE)

const BATCH_SIZE = 40;
const promises = [];

const newAliases = [
    {
        cca2: "AG",
        shortName: "antigua"
    },
    {
        cca2: "BA",
        shortName: "bosnie"
    },
    {
        cca2: "CD",
        shortName: "RDC"
    },
    {
        cca2: "MH",
        shortName: "marshall"
    },
    {
        cca2: "MK",
        shortName: "macedoine"
    },
    {
        cca2: "PG",
        shortName: "nouvelle guinee"
    },
    {
        cca2: "VC",
        shortName: "saint vincent"
    },
    {
        cca2: "KN",
        shortName: "saint christophe"
    },
    {
        cca2: "ST",
        shortName: "sao tome"
    },
    {
        cca2: "SB",
        shortName: "salomon"
    },
    {
        cca2: "TT",
        shortName: "trinite"
    },
    {
        cca2: "GB",
        shortName: "angleterre"
    }
]

for (let i = 0; i < newAliases.length; i++) {
    const country = {
        shortName: newAliases[i]['shortName'],
    };

    promises.push(() => supabase.from('countries_data').update(country).eq("cca2", newAliases[i]["cca2"]).then(({data, error}) => {
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
