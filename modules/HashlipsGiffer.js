const fs = require("fs");
const { GifEncoder } = require("@skyra/gifenc");

class HashlipsGiffer {
  constructor(_canvas, _ctx, _fileName, _repeat, _quality, _delay) {
    this.canvas = _canvas;
    this.ctx = _ctx;
    this.fileName = _fileName;
    this.repeat = _repeat;
    this.quality = _quality;
    this.delay = _delay;
    this.init();
  }

  init() {
    this.encoder = new GifEncoder(this.canvas.width, this.canvas.height);
    this.stream = this.encoder.createReadStream();
    this.encoder.start();
    this.encoder.setRepeat(this.repeat);
    this.encoder.setDelay(this.delay);
    this.encoder.setQuality(this.quality);
  }

  add() {
    this.encoder.addFrame(this.ctx);
  }

  stop() {
    this.encoder.finish();
    const buffer = fs.readFileSync(this.fileName);
    this.stream.pipe(fs.createWriteStream(this.fileName));
  }
}

module.exports = HashlipsGiffer;
