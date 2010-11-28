import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.utils.UIDUtil;

import util.Md5;

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
/**
 * 获得短签名
 */ 
public function shorturl(input:String):String {
	var base32:Array = [
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
		'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
		'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
		'y', 'z', '0', '1', '2', '3', '4', '5'
	];
	
	var hex:String =Md5.hex_md5(input);
	var hexLen:int = hex.length;
	var subHexLen:int = hexLen / 8;
	var output:String = "";
	
	for (var i:int = 0; i < 1; i++) {
		var subHex:String = hex.substr(i * 8, 8);
		var num:int = 0x3FFFFFFF & (1 * Number('0x'+ subHex));
		var out:String = '';
		
		for (var j:int = 0; j < 6; j++) {
			var val:int = 0x0000001F & num;
			out += base32[val];
			num = num >> 5;
		}
		
		output += out;
	}
	
	return output.substr(0,6);
}
/**
 * 生成uuid
 */ 
public function uuid():String{
	var u:String = UIDUtil.createUID();
	return u.replace(/-/g,'');
}
/**
 * 随机字符串(长度为6位)
 */ 
public function randomString():String{
	return shorturl(uuid());
}
/**
 * 生成一个缩写
 */ 
public function abbreviate(text:String,length:int):String{
	if(text == null){
		return '';
	}else if(text.length <= length){
		return text;
	}else{
		return text.substr(0,length -3) + '...';
	}
}
