const fs = require('fs');
const sax = require('sax');

const target = '527965468';
const parser = sax.createStream(true, { trim: true });

let currentTag = null;
let currentAttrs = {};
let insideSMS = false;
let insideMMS = false;

parser.on('opentag', node => {
  if (node.name === 'sms' && node.attributes.address.includes(target)) {
    insideSMS = true;
    currentAttrs = node.attributes;
  }

  if (node.name === 'mms' && node.attributes.address.includes(target)) {
    insideMMS = true;
    currentAttrs = node.attributes;
    currentAttrs.body = '';
  }

  if (insideMMS && node.name === 'part' && node.attributes.ct === 'text/plain') {
    currentAttrs.body += node.attributes.text + '\n';
  }
});

parser.on('closetag', name => {
  if (name === 'sms' && insideSMS) {
    console.log(`[SMS - ${currentAttrs.readable_date}] ${currentAttrs.type === '1' ? 'You:' : 'Them:'} ${currentAttrs.body}`);
    insideSMS = false;
    currentAttrs = {};
  }

  if (name === 'mms' && insideMMS) {
    console.log(`[MMS - ${currentAttrs.readable_date}] ${currentAttrs.msg_box === '1' ? 'You:' : 'Them:'} ${currentAttrs.body.trim()}`);
    insideMMS = false;
    currentAttrs = {};
  }
});

parser.on('error', err => console.error('SAX Error:', err));

parser._parser.MAX_BUFFER_LENGTH = 1024 * 1024 * 100; // 10 MB

fs.createReadStream(process.argv[2], { encoding: 'utf8' }).pipe(parser);

