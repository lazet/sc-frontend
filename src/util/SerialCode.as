package util
{
	import mx.controls.Alert;
	
	import org.lcf.IContainer;
	import org.lcf.IEventPrefer;
	import org.lcf.util.GeneralBundleEvent;
	import org.lcf.EventListenerModel;
	
	import rpc.RpcEvent;
	
	public class SerialCode implements IEventPrefer
	{
		private var type:String;
		private var number:int = 10;
		private var container:IContainer;
		
		public var currentCode:int = -1;
		
		private var key:String;
		private var usefulCodes:Array = new Array();
		
		/**
		 * 生成并管理指定流水号
		 * @param serialType String 流水号类型
		 */ 
		public function SerialCode(serialType:String, serialNumber:int, c:IContainer)
		{
			this.type = serialType;
			this.number = serialNumber;
			this.container = c;
		}
		public function init():void{
			var sendArg:Object = new Object();
			sendArg["number"] = this.number;
			this.container.dispatch(new RpcEvent("serial/consume",sendArg));
		}
		/**
		 * 获取下一个可用的流水号
		 */ 
		public function nextCode():int{
			if(this.usefulCodes.length == 5 || this.usefulCodes.length == 2 || this.usefulCodes.length == 0){
				init();
			}
			if(this.usefulCodes.length == 0){
				this.currentCode = -1;
				Alert.show("流水号已经用尽！请检查网络是否正常，以便获取新的流水号。","错误提醒");
				return this.currentCode;
			}
			this.currentCode = usefulCodes.pop() as int;
			return this.currentCode;
		}
		/**
		 * 注册事件监听程序定义
		 * 返回结果:
		 * 事件class的集合[new EventListenerModel(),new EventListenerModel()]
		 */ 
		public function get preferEventListeners():Array{
			var appendCode:EventListenerModel = new EventListenerModel("serial." + this.type,onAppend);
			return [appendCode];
		}
		public function onAppend(e:GeneralBundleEvent):void{
			var info:Object = e.bundle;
			this.key = info["key"];
			var start:int = info["value"] as int;
			var num:int = info["number"] as int;
			for(var k:int = 0; k < num; k++){
				usefulCodes.push(start - k);
			}
			if(currentCode == -1){
				this.nextCode();
			}
		}
	}
}