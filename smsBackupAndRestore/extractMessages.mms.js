const fs = require('fs');
const xmlFlow = require('xml-flow');

const TARGET = '527965468';
const [, , file] = process.argv;

if (!file) {
  console.error('Usage: node extract-sms.js <file.xml>');
  process.exit(1);
}

console.log("WHAT THE FUCK");
const stream = fs.createReadStream(file);
const xml = xmlFlow(stream);

xml.on('startElement', name => {
  console.log('START:', name);
});


xml.on('tag:*', (node) => {
	console.log("tag");
  if (node['$name'] === 'mms') {
    console.log('Found <mms>:', node.readable_date);
  }
	console.log(node['$name']);
});


// Extract SMS messages
xml.on('tag:sms', msg => {
  if (msg.address.includes(TARGET)) {
    const who = msg.type === '1' ? 'You:' : 'Them:';
    console.log(`[SMS - ${msg.readable_date}] ${who} ${msg.body}`);
  }
});

// Extract MMS messages
xml.on('tag:mms', msg => {
	console.log("checking mms");
  if (!msg.address || ! msg.address.includes(TARGET)) return;

  let bodyText = '';

  // Handle MMS parts (can be array or object)
  const parts = msg.parts?.part;
  if (Array.isArray(parts)) {
    for (const p of parts) {
      if (p.ct === 'text/plain' && p.text) {
        bodyText += p.text + '\n';
      }
    }
  } else if (parts?.ct === 'text/plain' && parts.text) {
    bodyText += parts.text;
  }

  if (bodyText.trim()) {
    const who = msg.msg_box === '1' ? 'You:' : 'Them:'; // 1 = sent, 2 = received
    console.log(`[MMS - ${msg.readable_date}] ${who} ${bodyText.trim()}`);
  }
});

xml.on('end', () => {
  console.log('Done.');
});

