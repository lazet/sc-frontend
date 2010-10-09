package rpc
{
	import json.JParser;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.lcf.EventListenerModel;
	import org.lcf.IContainer;
	import org.lcf.IEventPrefer;
	import org.lcf.util.GeneralBundleEvent;
	
	public class RpcService implements IEventPrefer
	{
		static public var RPC_SERVICE:String = "RPC_SERVICE";
		[Inject(name="container")]
		public var c:IContainer;
		
		private var prefix:String;
		
		public function get preferEventListeners():Array
		{
			var rpcModel:EventListenerModel = new EventListenerModel(RpcEvent.RPC_EVENT,call);
			return [rpcModel];
		}
		private function call(re:RpcEvent):void{
			var client:HTTPService = new HTTPService();
			client.contentType = "application/json";
			client.resultFormat = "text";
			
			client.url = prefix + re.url;
			client.method = re.method;
			client.addEventListener(ResultEvent.RESULT,onCall);
			client.addEventListener(FaultEvent.FAULT,onError);
			client.send(re.args);
		}
		
		private function onCall(e:ResultEvent):void{
			if(c!=null){
				var result:Object = JParser.decode( e.message.body.toString() );
				c.dispatch(new GeneralBundleEvent(result["type"],result["content"]));
			}
		}
		public function RpcService(prefix:String)
		{
			this.prefix = prefix;
		}
		
		private function onError(e:FaultEvent):void{
			Alert.show(e.fault.faultCode + ' ' + e.fault.faultDetail,"网络访问错误");
		}
	}
}