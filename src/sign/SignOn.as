package sign
{
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	
	import org.lcf.EventListenerModel;
	import org.lcf.IContainer;
	import org.lcf.IEventPrefer;
	import org.lcf.util.GeneralBundleEvent;
	
	import rpc.RpcEvent;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class SignOn extends SkinnableComponent implements org.lcf.IEventPrefer
	{
		public static var SIGN_ON_SUCCESS_EVENT:String = "signOn.success";
		public static var SIGN_ON_FAILED_EVENT:String = "signOn.failed";
		
		[Inject(name="container")]
		public var c:IContainer;
		
		[SkinPart(required="true")]
		public var unitName:TextInput;
		
		[SkinPart(required="true")]
		public var loginName:TextInput;
		
		[SkinPart(required="true")]
		public var password:TextInput;
		
		[SkinPart(required="true")]
		public var signOn:Button;
		
		public function SignOn()
		{
			super();
			this.setStyle("skinClass",SignOnSkin);
		}
		
		public function get preferEventListeners():Array
		{
			var signOnSuccess:EventListenerModel = new EventListenerModel(SIGN_ON_SUCCESS_EVENT,onSignOnSuccess);
			var signOnFailed:EventListenerModel = new EventListenerModel(SIGN_ON_FAILED_EVENT,onSignOnFailed);
			
			return [signOnSuccess,signOnFailed ];
		}
		public function onSignOnSuccess(e:GeneralBundleEvent):void{
			Alert.show("登录成功");
		}
		public function onSignOnFailed(e:GeneralBundleEvent):void{
			Alert.show("登录失败:" + e.bundle);
		}
		public function onSignOn(e:MouseEvent):void{
			if(unitName.text == ""){
				Alert.show("单位名称不能为空");
				return;
			}
			if(loginName.text == ""){
				Alert.show("用户名不能为空");
				return;
			} 
			if(password.text == ""){
				Alert.show("密码不能为空");
				return;
			}
			var o:Object = new Object();
			o.loginName = loginName.text;
			o.unitName = unitName.text;
			o.password = password.text;
			
			c.dispatch(new RpcEvent("sign/signOn", o));
		}
		
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == this.signOn){
				this.signOn.addEventListener(MouseEvent.CLICK,this.onSignOn);
				
			}
		}
		override protected function partRemoved(partName:String, instance:Object):void{
			if(instance == this.signOn){
				this.signOn.removeEventListener(MouseEvent.CLICK,this.onSignOn);
			}
		}
	}
}