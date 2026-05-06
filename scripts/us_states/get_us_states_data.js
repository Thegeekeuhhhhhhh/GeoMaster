import { createClient } from '@supabase/supabase-js'
import { loadEnvFile } from 'node:process';
loadEnvFile('../.env');

const supabase = createClient(process.env.CLIENT_URL, process.env.SERVICE_ROLE)

const DEBUG=false

const url = 'https://us-states.p.rapidapi.com/basic';
const options = {
	method: 'GET',
	headers: {
		'x-rapidapi-key': process.env.X_RAPIDAPI_KEY_US_STATES,
		'x-rapidapi-host': 'us-states.p.rapidapi.com',
		'Content-Type': 'application/json'
	}
};

let json = [];

const response = await fetch(url, options);
json = await response.json();

const usStateList = [];

for (let i = 0; i < json.length; i++) {
	const state = {
		id: json[i]["postal"],
		name: json[i]["name"],
		capital: json[i]["capital"]["name"],
		population: json[i]["population"]["total"],
	};

	usStateList.push(state);
}

const { data, error } = await supabase.from('us_states_data').insert(usStateList);
console.log({
    data: data,
    error: error,
});
