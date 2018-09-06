# MResourceLoader

### CocoaPods

`pod 'MResourceLoader'`

### Usage

**Objective C**

```Objc
NSURL *url = [NSURL URLWithString:@"http://www.w3school.com.cn/example/html5/mov_bbb.mp4"];

self.loader = [MResourceLoader new]; // instance hold mresourceloader
AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[MResourceScheme mrSchemeURL:url] options:nil];
[asset.resourceLoader setDelegate:self.loader queue:dispatch_get_main_queue()];

AVPlayerItem *playitem = [AVPlayerItem playerItemWithAsset:asset];
AVPlayer *player = [AVPlayer playerWithPlayerItem:playitem];
AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:player];
playLayer.frame = CGRectMake(50, 100, 300, 400);
playLayer.backgroundColor = [UIColor blackColor].CGColor;
[self.view.layer addSublayer:playLayer];
[player play];
```
### Contact

miaochaomc@163.com  
miaochaomc@gmail.com

### License

MIT
