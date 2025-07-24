const fs = require('fs');
const xmlFlow = require('xml-flow');

const TARGET = '527965468';
const [, , file] = process.argv;

if (!file) {
  console.error('Usage: node extract-sms.js <file.xml>');
  process.exit(1);
}

const stream = fs.createReadStream(file);
const xml = xmlFlow(stream);

xml.on('tag:sms', msg => {
  if (msg.address.includes(TARGET)) {
    const who = msg.type === '1' ? 'You:' : 'Them:';
    console.log(`[${msg.readable_date}] ${who} ${msg.body}`);
  }
});

xml.on('end', () => console.log('Done.'));

