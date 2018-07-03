package
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.VideoLoader;
	import com.greensock.loading.XMLLoader;
	import com.kio.tools.display.KioSprite;
	import com.kio.tools.udp.UDPReceivedDataEvent;
	
	import flash.events.Event;
	
	[SWF(backgroundColor="#000000", frameRate="30",width="400",height="300")]
	public class KIO_AudioPlayer extends KioSprite
	{
		//loading sequence
		private var loaderMax:LoaderMax;		
		private var xmlConfig:XML;	
		
		private var ipLoader:MP3Loader;
		//		private var ipMovie:ContentDisplay;
		
		private var repeatCount:int = -1;
		private var playedCount:int = 0;
		
		private var audioList:Vector.<String>;
		
		public function KIO_AudioPlayer()
		{
			super("视频播放器",55555,0,true,false,true);	
			this.addEventListener(Event.ADDED_TO_STAGE,initXML);
		}
		
		//读取XML
		private function initXML(e:Event):void{
			LoaderMax.activate([ImageLoader, SWFLoader, VideoLoader, MP3Loader]);
			loaderMax = new LoaderMax({onComplete:initStage});
			loaderMax.append(new XMLLoader("config.xml",{name:"xmlConfigCom"}));
			loaderMax.load();	
		}
		
		private function initStage(e:LoaderEvent):void{		
			xmlConfig = LoaderMax.getContent("xmlConfigCom");	
			
			//通信设置
			initUDP(parseInt(xmlConfig.UDP[0].Port[0]),0);
			
			//载入音频列表
			audioList = new Vector.<String>();
			for(var i:int=0;i<xmlConfig.LoaderMax[0].children().length();i++){
				audioList[i] = xmlConfig.LoaderMax[0].MP3Loader[i].@name;
			}						
			//音频设置
			ipLoader = LoaderMax.getLoader("audio1");
//			ipLoader.playSound();
		}
		
		protected override function socketDataReceived(evt:UDPReceivedDataEvent):void
		{
			//			trace("received:"+evt.data);
			evt.data = evt.data.toLowerCase();	
			
			for(var i:int=0;i<audioList.length;i++){
				if(evt.data==audioList[i]) {
					ipLoader.pauseSound();
					ipLoader = LoaderMax.getLoader(audioList[i]);
					ipLoader.gotoSoundTime(0,true);
				}
				
			}
			
			switch(evt.data){
				case "replay":	
					ipLoader.gotoSoundTime(0,true);
					break;
				case "play":
					ipLoader.playSound();
					break;
				case "stop":
					ipLoader.pauseSound();
					break;
				case "pause":
					if(ipLoader.soundPaused)
						ipLoader.playSound();
					else
						ipLoader.pauseSound();
					break;
				case "volumedown":
					ipLoader.volume -=0.05;
					if(ipLoader.volume <0)
						ipLoader.volume = 0;
					break;
				case "volumeup":
					ipLoader.volume +=0.05;
					if(ipLoader.volume >1)
						ipLoader.volume = 1;
					break;
			}
			
			
		}
	}
}