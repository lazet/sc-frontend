package rpc
{
	import flash.events.Event;
	
	import org.lcf.util.GeneralBundleEvent;
	
	public class RpcEvent extends Event
	{
		static public var RPC_EVENT:String = "RPC_EVENT";
		public function RpcEvent(url:String,args:Object,method:String="GET"){
			super(RPC_EVENT);
			this.url = url;
			this.method = method;
			this.args = args;
		}
		public var url:String;
		
		public var method:String;
		
		public var args:Object;
	}
}