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
	
	import sign.SignInfo;
	
	import util.Consts;
	import util.Md5;
	import util.ObjectNameDefine;
	
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
			client.resultFormat = "text";
			
			client.url = prefix + re.url;
			client.method = "POST";
			client.addEventListener(ResultEvent.RESULT,onCall);
			client.addEventListener(FaultEvent.FAULT,onError);
			if(re.url.indexOf("sign/") != 0){
				//加密并生成验证信息
				var encryptCode:Number = 0;
				for(var prop:String in re.args){
					if(re.args[prop] == null)
						re.args[prop] = '';
					if( prop == ObjectNameDefine.ENCRYPT_CODE || 
						prop == ObjectNameDefine.SESSION_ID)
						continue;
					var hexMd5:String = Md5.hex_md5(prop + re.args[prop]);
					var shortHex:String = hexMd5.substr(0,6);
					var value:Number = Number('0x' + shortHex);
					encryptCode = encryptCode + value;
				}
				//用password加密
				var si:SignInfo = this.c.get(SignInfo.SIGN_INFO) as SignInfo;
				var p:String = si.token;
				var s:String = this.c.get(ObjectNameDefine.SESSION_ID) as String;
				var appendMd5:String = Md5.hex_md5(p + s + Consts.MIX_CODE);
				var appendHex:String = appendMd5.substr(0,6);
				var appendValue:Number = Number('0x' + appendHex)
				encryptCode = encryptCode + appendValue;
				re.args[ObjectNameDefine.SESSION_ID] = s;
				re.args[ObjectNameDefine.ENCRYPT_CODE] = encryptCode;
				
			}
			client.send(re.args);
		}
		
		private function onCall(e:ResultEvent):void{
			if(c!=null){
				var result:Object = JParser.decode( e.message.body.toString() );
				if(result != null){
					c.dispatch(new GeneralBundleEvent(result["type"],result["content"]));
				}
				else
					Alert.show("安全认证失败，请联系本系统运营服务人员","系统错误");
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