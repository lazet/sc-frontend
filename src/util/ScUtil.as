import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * 持续调用一个方法直到成功,或达到最大次数为止
 * @func Function 要调用的方法，需以Boolean为返回值，且无需传参数
 * @interval int 每个多少毫秒调用一次 1000代表一秒
 * @maxTimes 最大调用次数，为0时为无限次
 * @lizhantao
 */ 
public function callUtilSuccess(func:Function, interval:int = 5000, maxTimes:int= 0):void{
	var r:Boolean = func() as Boolean;
	
	if(!r && (maxTimes >1 ||  maxTimes == 0)){
		var t:Timer = new Timer(interval,maxTimes > 1?maxTimes -1:0);
		t.addEventListener(TimerEvent.TIMER,function(event:TimerEvent):void{
			var result:Boolean = func() as Boolean;
			if(result){
				t.stop();
				t = null;
			}
		});
		t.start();
	}
}

public function decodePeriod(period:String):Array{
	var hours:Array = new Array();
	
	var segments:Array = period.split(",");
	for(var i:int; i< segments.length;i ++ ){
		var seg:String = segments[i];
		var pair:Array = seg.split("-");
		var start:int = parseInt(pair[0]);
		var end:int = parseInt(pair[1]);

		for(var j:int= start; j < end; j++){
			hours[j] = 1
		}
	}

	return hours;
}

public function exist(item:String,items:Array):Boolean{
	if(items == null)return false;
	for(var i:int = 0;i< items.length;i++){
		if(item == items[i]){
			return true;
		}
	}
	return false;
}
