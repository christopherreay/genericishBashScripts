const fs = require('fs');
const { SaxesParser } = require('saxes');

const target = '527965468';

const parser = new SaxesParser({ xmlns: false });

let currentTag = null;
let currentAttrs = null;
let inMMS = false;
let mmsText = '';

parser.on('error', err => {
  console.error('Parser error:', err.message);
});

parser.on('opentag', node => {
  if (node.name === 'sms' && node.attributes.address.includes(target)) {
    const who = node.attributes.type === '1' ? 'You:' : 'Them:';
    console.log(`[SMS - ${node.attributes.readable_date}] ${who} ${node.attributes.body}`);
  }

  if (node.name === 'mms' && node.attributes.address.includes(target)) {
    //console.log("in mms");
	  inMMS = true;
    currentAttrs = node.attributes;
    mmsText = '';
  }

  if (inMMS && node.name === 'part' &&
	  node.attributes.ct === 'text/plain' &&
      node.attributes.text) {
	 // console.log("mms part: "+node.attributes.text);
    mmsText += node.attributes.text + '\n';
  }
});

parser.on('closetag', tag => {
  if (tag.name === 'mms' && inMMS && mmsText.trim()) {
    const who = currentAttrs.msg_box === '1' ? 'You:' : 'Them:';
    console.log(`[MMS - ${currentAttrs.readable_date}] ${who} ${mmsText.trim()}`);
    inMMS = false;
    currentAttrs = null;
    mmsText = '';
  }
});

const stream = fs.createReadStream(process.argv[2], { encoding: 'utf8' });
stream.on('data', chunk => parser.write(chunk));
stream.on('end', () => parser.close());

