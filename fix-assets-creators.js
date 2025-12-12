const fs = require('fs');
const path = require('path');

const assetsDir = path.join(__dirname, 'assets');

// Get all JSON files
const files = fs.readdirSync(assetsDir).filter(f => f.endsWith('.json'));

console.log(`🔄 Processing ${files.length} JSON files...`);

let processed = 0;

files.forEach(file => {
  const filePath = path.join(assetsDir, file);
  
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const metadata = JSON.parse(content);
    
    // Remove the deprecated creators field from properties
    if (metadata.properties && metadata.properties.creators) {
      delete metadata.properties.creators;
      
      // Write back without creators
      fs.writeFileSync(filePath, JSON.stringify(metadata, null, 2));
      processed++;
      
      if (processed % 1000 === 0) {
        console.log(`✅ Processed: ${processed}/${files.length}`);
      }
    }
  } catch (error) {
    console.error(`❌ Error processing ${file}:`, error.message);
  }
});

console.log(`\n✨ Done! Fixed ${processed} files`);
