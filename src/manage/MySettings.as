package manage
{
	import flash.events.MouseEvent;
	import flash.system.IME;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.validators.Validator;
	
	import org.lcf.EventListenerModel;
	import org.lcf.IContainer;
	import org.lcf.IEventPrefer;
	import org.lcf.util.GeneralBundleEvent;
	
	import rpc.RpcEvent;
	import rpc.RpcService;
	
	import sign.SignInfo;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;

	/**
	 * 个人信息设定
	 */ 
	public class MySettings extends SkinnableComponent implements org.lcf.IEventPrefer
	{
		[SkinPart(required="true")]
		public var loginName:TextInput;
		
		[SkinPart(required="true")]
		public var oldPass:TextInput;
		
		[SkinPart(required="true")]
		public var newPass:TextInput;
		
		[SkinPart(required="true")]
		public var newPass2:TextInput;
		
		[SkinPart(required="true")]
		public var trueName:TextInput;
		
		[SkinPart(required="true")]
		public var mobile:TextInput;
		
		[SkinPart(required="true")]
		public var email:TextInput;
		
		[SkinPart(required="true")]
		public var cancelButton:Button;
		
		[SkinPart(required="true")]
		public var saveButton:Button;
		
		[SkinPart(required="true")]
		public var oldPassValidate:Validator;
		[SkinPart(required="true")]
		public var newPassValidate:Validator;
		[SkinPart(required="true")]
		public var newPass2Validate:Validator;
		[SkinPart(required="true")]
		public var emailValidate:Validator;
		[SkinPart(required="true")]
		public var mobileValidate:Validator;
		[SkinPart(required="true")]
		public var trueNameValidate:Validator;
		[SkinPart(required="true")]
		public var inconsistenceValidate:Validator;
		
		private var c:IContainer;
		
		private var userInfo:SignInfo;
		
		public function MySettings(c:IContainer)
		{
			super();
			this.c = c;
			c.put("mySettings",this);
			this.setStyle("skinClass", MySettingsSkin);
			this.addEventListener(FlexEvent.CREATION_COMPLETE,onInit);
		}
		public function onInit(e:FlexEvent):void{
			this.userInfo = c.get(SignInfo.SIGN_INFO) as SignInfo;
			var arg:Object = new Object();
			arg.loginName = userInfo.loginName;
			arg.unitName  = userInfo.unitName;
			this.c.dispatch(new RpcEvent("mySettings/get",arg));
			IME.enabled = true;
		}
		public function onGetMySettings(e:GeneralBundleEvent):void{
			var info:Object = e.bundle;
			this.loginName.text = info.loginName;
			this.trueName.text  = info.trueName;
			this.mobile.text    = info.mobile;
			this.email.text     = info.email;
			
		}
		public function onGetMySettingsFailed(e:GeneralBundleEvent):void{
			Alert.show("加载信息失败：" + e.bundle.toString());
			
		}
		public function onSaveSuccess(e:GeneralBundleEvent):void{
			this.onCancel(null);
		}
		public function onSaveFailed(e:GeneralBundleEvent):void{
			Alert.show("保存信息失败：" + e.bundle.toString());
		}
		public function get preferEventListeners():Array{
			var getInfo:EventListenerModel = new EventListenerModel("getMySettings.success",onGetMySettings);
			var getInfoFailed:EventListenerModel = new EventListenerModel("getMySettings.failed",onGetMySettingsFailed);
			var saveInfo:EventListenerModel = new EventListenerModel("saveMySettings.success",onSaveSuccess);
			var saveInfoFailed:EventListenerModel = new EventListenerModel("saveMySettings.failed",onSaveFailed);
			return [getInfo,getInfoFailed,saveInfo,saveInfoFailed];
		}
		public function onSave(e:MouseEvent):void{
			var all:Array=Validator.validateAll([oldPassValidate,newPassValidate,newPass2Validate,inconsistenceValidate,emailValidate,mobileValidate,trueNameValidate]);
			if(all.length >0){
				return;
			}
			var arg:Object = new Object();
			arg.loginName = this.userInfo.loginName;
			arg.unitName  = this.userInfo.unitName;
			arg.oldPass = this.oldPass.text;
			arg.newPass = this.newPass.text;
			arg.mobile  = this.mobile.text;
			arg.email   = this.email.text;
			arg.trueName = this.trueName.text;
			
			this.c.dispatch(new RpcEvent("mySettings/save",arg));
			
		}
		public function onCancel(e:MouseEvent):void{
			PopUpManager.removePopUp(this);
			this.oldPass.text = "";
			this.newPass.text = "";
			this.newPass2.text = "";
		}
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == this.saveButton){
				this.saveButton.addEventListener(MouseEvent.CLICK,onSave);
			}
			else if( instance == this.cancelButton){
				this.cancelButton.addEventListener(MouseEvent.CLICK,onCancel);
			}
		}
		override protected function partRemoved(partName:String, instance:Object):void{
			if(instance == this.saveButton){
				this.saveButton.removeEventListener(MouseEvent.CLICK,onSave);
			}
			else if( instance == this.cancelButton){
				this.cancelButton.removeEventListener(MouseEvent.CLICK,onCancel);
			}
		}
	}
}