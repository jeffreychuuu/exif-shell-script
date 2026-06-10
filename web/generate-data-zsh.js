const fs = require('fs');
const data = JSON.parse(fs.readFileSync('data.json', 'utf8'));

function zshArr(values) {
  return '(' + values.map(v => `"${v}"`).join(' ') + ')';
}

const lines = [];

lines.push('AUTHORS=' + zshArr(data.authors));
lines.push('');

const camEntries = [];
data.cameras.forEach((c, i) => {
  camEntries.push(`"${c.make}|${c.model}"`);
  const lensEntries = c.lenses.map(l => `"${l.name}|${l.focal}|${l.aperture}"`);
  const name = ['LEICA_LENSES', 'OLYMPUS_LENSES', 'LOMOGRAPHY_SIMPLE_USE_LENSES'][i];
  lines.push(`${name}=(${lensEntries.join(' ')})`);
});
lines.push('CAMERAS=' + zshArr(data.cameras.map(c => `${c.make}|${c.model}`)));
lines.push('');

const filmEntries = data.films.map(f => `"${f.name}|${f.iso}"`);
lines.push('FILMS=(' + filmEntries.join(' ') + ')');
lines.push('');

['labs', 'processes', 'pushpulls', 'scanners'].forEach(key => {
  lines.push(`${key.toUpperCase()}=${zshArr(data[key])}`);
});

fs.writeFileSync('data.zsh', lines.join('\n') + '\n');
console.log('Generated data.zsh');
