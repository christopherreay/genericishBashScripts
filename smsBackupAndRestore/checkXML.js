const fs = require('fs');
const xmlFlow = require('xml-flow');
const stream = fs.createReadStream('sms-20250602214344.xml');
const xml = xmlFlow(stream);

xml.on('tag:*', (node) => {
  if (node['$name'] === 'mms') {
    console.log('Found <mms>:', node.readable_date);
  }
});

xml.on('end', () => console.log('Done'));

