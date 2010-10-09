package sign
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import manage.ManagerView;
	
	import mx.controls.Alert;
	import mx.validators.StringValidator;
	import mx.validators.Validator;
	
	import org.lcf.EventListenerModel;
	import org.lcf.IComponent;
	import org.lcf.IContainer;
	import org.lcf.IEventPrefer;
	import org.lcf.util.GeneralBundleEvent;
	import org.lcf.util.ModuleEvent;
	
	import rpc.RpcEvent;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class SignOn extends SkinnableComponent implements org.lcf.IComponent
	{
		public static var SIGN_ON_SUCCESS_EVENT:String = "signOn.success";
		public static var SIGN_ON_FAILED_EVENT:String = "signOn.failed";
		
		public var c:IContainer;
		
		private var signOnInfo:Object;
		
		public function set container(c:IContainer):void{
			this.c = c;
		}
		
		[SkinPart(required="true")]
		public var unitName:TextInput;
		
		[SkinPart(required="true")]
		public var loginName:TextInput;
		
		[SkinPart(required="true")]
		public var password:TextInput;
		
		[SkinPart(required="true")]
		public var signOn:Button;
		
		
		[SkinPart(required="true")]
		public var unitNameValidate:StringValidator;
		[SkinPart(required="true")]
		public var loginNameValidate:StringValidator;
		[SkinPart(required="true")]
		public var passwordValidate:StringValidator;
		
		public function SignOn()
		{
			super();
			this.percentHeight = 100;
			this.percentWidth  = 100;
			this.setStyle("skinClass",SignOnSkin);
			this.addEventListener(KeyboardEvent.KEY_UP,onKeyBoardEvent);
		}
		
		public function get preferEventListeners():Array
		{
			var signOnSuccess:EventListenerModel = new EventListenerModel(SIGN_ON_SUCCESS_EVENT,onSignOnSuccess);
			var signOnFailed:EventListenerModel = new EventListenerModel(SIGN_ON_FAILED_EVENT,onSignOnFailed);
			
			return [signOnSuccess,signOnFailed ];
		}
		public function onSignOnSuccess(e:GeneralBundleEvent):void{
			//填写公共信息
			this.c.put(SignInfo.SIGN_INFO,new SignInfo(this.signOnInfo.unitName,this.signOnInfo.loginName,this.signOnInfo.password ));
			//清理登录信息
			password.text = '';
			//切换到管理页面
			this.c.dispatch(new ModuleEvent(org.lcf.Constants.OPEN_MODULE_EVENT,"manageView","管理主界面",new ManagerView()));
			
		}
		public function onSignOnFailed(e:GeneralBundleEvent):void{
			this.password.text = '';
			Alert.show("登录失败:" + e.bundle);
		}
		public function onSignOn(e:MouseEvent):void{
			var all:Array=Validator.validateAll([unitNameValidate,loginNameValidate,passwordValidate]);
			if(all.length >0){
				return;
			}
			var o:Object = new Object();
			o.loginName = loginName.text;
			o.unitName = unitName.text;
			o.password = password.text;
			this.signOnInfo = o;
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
		public function onKeyBoardEvent(e:KeyboardEvent):void{
			switch(e.keyCode){
				case 13:
					this.onSignOn(null);
					break;

			}
		}
	}
}