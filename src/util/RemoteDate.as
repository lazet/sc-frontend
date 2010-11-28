package util
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.formatters.DateFormatter;
	
	import org.lcf.IContainer;
	import org.lcf.util.GeneralBundleEvent;

	public class RemoteDate  
	{
		public var internalDate:Date;
		public var timer:Timer;
		public var c:IContainer;
		
		public function RemoteDate(date:String,container:IContainer = null)
		{
			internalDate = parse(date);
			this.c = container;
			timer = new Timer(60000);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			timer.start();
		}
		public function onTimer(e:TimerEvent):void{
			internalDate.minutes +=1;
			if(internalDate.minutes == 0 && c != null){
				c.dispatch(new GeneralBundleEvent(EventTypeDefine.TIME_HOUR_EVENT,internalDate.hours));
			}
			if(c != null)
				c.dispatch(new GeneralBundleEvent(EventTypeDefine.TIME_MINUTE_EVENT,getTime()));
		}
		public function getTime():String{
			var df:DateFormatter = new DateFormatter();
			df.formatString = "YYYY-MM-DD JJ:NN:SS";
			return df.format(internalDate);
		}
		public function getDate():String{
			var df:DateFormatter = new DateFormatter();
			df.formatString = "YYYY-MM-DD";
			return df.format(internalDate);
		}
		public function getHour():String{
			var df:DateFormatter = new DateFormatter();
			df.formatString = "JJ";
			return df.format(internalDate);
		}
		
		private function parse( str:String ): Date {
			//get each number in an array
			var match:Array = str.match( /\d+/g );
			
			//if there were no miliseconds, add 0 to the end
			if( match.length < 7 ) match.push('0');
			
			return new Date( Number(match[0]), Number(match[1]) -1, Number(match[2]), Number(match[3]), Number(match[4]), Number(match[5]), Number(match[6]) );
		}
	}
}