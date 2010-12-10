package sign
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import manage.ManagerView;
	
	import mx.controls.Alert;
	import mx.validators.StringValidator;
	import mx.validators.Validator;
	
	import operate.OperatorView;
	
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
	
	import util.ObjectNameDefine;
	import util.RemoteDate;
	
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
			var getNow:EventListenerModel = new EventListenerModel("now",onGetNow);
			return [signOnSuccess,signOnFailed,getNow ];
		}
		public function onGetNow(e:GeneralBundleEvent):void{
			var now:String = String(e.bundle);
			this.c.put(ObjectNameDefine.NOW,new RemoteDate(now,this.c));			
			var today:String = now.substr(0,now.indexOf(" "));
			this.c.put(ObjectNameDefine.TODAY,today);
		}
		public function onSignOnSuccess(e:GeneralBundleEvent):void{
			//填写公共信息
			this.c.put(SignInfo.SIGN_INFO,new SignInfo(this.signOnInfo.unitName,this.signOnInfo.loginName,this.signOnInfo.password ));
			//清理登录信息
			password.text = '';
			this.c.dispatch(new RpcEvent("data/now",{}));
			//判断是否有权登录多个桌面
			var desktops:Array = getDesktops(e.bundle);
			this.c.put(ObjectNameDefine.DESKTOPS , desktops);
			if(desktops.length == 0 ){
				Alert.show("提示","当前用户无权进入本系统");
			}
			else if(desktops.length == 1 ){
				//切换到管理页面
				if(util.ObjectNameDefine.MANAGER_VIEW == desktops[0]["url"])
					this.c.dispatch(new ModuleEvent(org.lcf.Constants.OPEN_MODULE_EVENT,util.ObjectNameDefine.MANAGER_VIEW,"信息中心",new ManagerView()));
				else
					this.c.dispatch(new ModuleEvent(org.lcf.Constants.OPEN_MODULE_EVENT,util.ObjectNameDefine.OPERATOR_VIEW,"收银台",new OperatorView()));
			}
			else{
				var n:Navigator = new Navigator(this.c,desktops);
				this.c.dispatch(new ModuleEvent(org.lcf.Constants.OPEN_MODULE_EVENT,util.ObjectNameDefine.NAVIGATOR_VIEW,"导航页面",n));
			}
			
			
			
		}
		/**
		 * 获取当前用户所能登录的桌面集合
		 */ 
		public function getDesktops(curentUserInfo:Object):Array{
			var roles:Array = curentUserInfo["roles"] as Array;
			var desktops:Dictionary = new Dictionary();
			if(roles != null){
				for(var i:int =0; i < roles.length;i++){
					var powers:Array = roles[i]["powers"];
					if(powers != null){
						for(var j:int=0; j< powers.length;j++){
							if("OPERATOR_VIEW" == powers[j]["url"]){
								powers[j]["icon"] = "assets/cashier.jpg";
								desktops[(powers[j]["url"])] = powers[j];
							}
							else if ( "MANAGER_VIEW" ==  powers[j]["url"]) {
								powers[j]["icon"] = "assets/manager.jpg";
								desktops[(powers[j]["url"])] = powers[j];
							}
						}
					}
				}
			}
			var desktopArray:Array = new Array();
			for(var a:String in desktops){
				desktopArray.push(desktops[a]);
			}
			return desktopArray;
			
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