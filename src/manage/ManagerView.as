package manage
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.LinkButton;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import operate.OperatorView;
	
	import org.lcf.Constants;
	import org.lcf.IComponent;
	import org.lcf.IContainer;
	import org.lcf.IModuleManager;
	import org.lcf.Overlay;
	import org.lcf.util.ModuleEvent;
	
	import rpc.RpcService;
	
	import sign.SignInfo;
	
	import spark.components.ButtonBar;
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	
	import util.ObjectNameDefine;
	
	public class ManagerView extends SkinnableComponent implements IComponent
	{
		[SkinPart(required="true")]
		public var unitName:Label;
		[SkinPart(required="true")]
		public var loginName:LinkButton;
		[SkinPart(required="true")]
		public var exit:LinkButton;
		[SkinPart(required="true")]
		public var toolBar:ButtonBar;
		[SkinPart(required="true")]
		public var content:Overlay;
		[SkinPart(required="true")]
		public var switchView:DropDownList;

		public var mySettings:MySettings;
		
		protected var c:IContainer;
		
		public function set container(c:IContainer):void{
			this.c = c;
			this.init();
		}
		public function get preferEventListeners():Array
		{
			//var signOffSuccess:EventListenerModel = new EventListenerModel(SIGN_OFF_SUCCESS_EVENT,onSignOffSuccess);
			//将来添加对多个桌台的切换事件处理
			return [ ];
		}
		
		protected function onSignOffSuccess(e:MouseEvent):void{
			
		}
		public function ManagerView()
		{
			super();
			this.percentWidth = 100;
			this.percentHeight = 100;
			this.setStyle("skinClass",ManagerViewSkin);
		}
		protected function init():void{
			
		}
		protected function onExitClicked(e:MouseEvent):void{
			Alert.show("确定要退出系统吗？","系统提示",Alert.OK | Alert.CANCEL,this,onExit);
		}
		protected function onExit(e:CloseEvent):void{
			if(e.detail == Alert.OK){
				var mm:IModuleManager = this.c.get(Constants.OVERLAY) as IModuleManager;
				mm.closeOther("signOn");
			}
		}
		protected function onSwitchView(e:IndexChangeEvent):void{
			if(this.switchView.selectedItem["id"] == ObjectNameDefine.OPERATOR_VIEW){
				this.c.dispatch(new ModuleEvent(org.lcf.Constants.OPEN_MODULE_EVENT,util.ObjectNameDefine.OPERATOR_VIEW,"前台交易",new OperatorView()));
			}
			this.switchView.selectedIndex = 0;
			e.preventDefault();
		}
		protected function onSwitchContent(e:IndexChangeEvent):void{
			var bb:ButtonBar = ButtonBar(e.target);
			this.content.open(bb.selectedItem.url,bb.selectedItem.name,bb.selectedItem.url);
		}
		protected function onMySettings(e:MouseEvent):void{
			if(this.mySettings == null){
				this.mySettings = new MySettings(this.c);
			}
			PopUpManager.addPopUp(this.mySettings,this,true);
			PopUpManager.centerPopUp(this.mySettings);
		}
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == this.unitName){
				this.unitName.text = (this.c.get(SignInfo.SIGN_INFO) as SignInfo).unitName;
			}
			else if (instance == this.loginName){
				this.loginName.label = (this.c.get(SignInfo.SIGN_INFO) as SignInfo).loginName;
				this.loginName.addEventListener(MouseEvent.CLICK,onMySettings);
			}
			else if (instance == this.exit){
				this.exit.addEventListener(MouseEvent.CLICK,onExitClicked);
			}
			else if (instance == this.toolBar){
				this.toolBar.requireSelection= true;
				this.toolBar.labelField = "name";
				this.toolBar.dataProvider = new ArrayCollection([{"url":"manage/modules/main/MainPage.swf","name":"首页"},{"url":"manage/modules/resource/Resources.swf","name":"资源"},{"url":"manage/modules/marketing/Marketings.swf","name":"营销"},{"url":"manage/modules/report/Reports.swf","name":"报表"},{"url":"manage/modules/settings/System.swf","name":"系统"}]);
				this.toolBar.addEventListener(IndexChangeEvent.CHANGE,onSwitchContent);
			}
			else if (instance == this.switchView){
				this.switchView.requireSelection = true;
				this.switchView.labelField = "name";
				this.switchView.dataProvider = new ArrayCollection([{"id":ObjectNameDefine.MANAGER_VIEW,"name":"后台管理"},{"id":ObjectNameDefine.OPERATOR_VIEW,"name":"前台交易"}]);
				this.switchView.addEventListener(IndexChangeEvent.CHANGE,onSwitchView);
			}
			else if (instance == this.content){
				this.content.container.parentContainer = this.c;
				//加载RPC服务
				var info:SysInfo = c.get(SysInfo.SYSTEM_INFO) as SysInfo;
				var rpcClient:RpcService = new RpcService(info.remoteSiteUrl);
				this.content.container.put(RpcService.RPC_SERVICE, rpcClient)
				this.content.open("manage/modules/main/MainPage.swf","首页","manage/modules/main/MainPage.swf");
			}
		}
		override protected function partRemoved(partName:String, instance:Object):void{
			if (instance == this.exit){
				this.exit.removeEventListener(MouseEvent.CLICK,onExitClicked);
			}
			else if (instance == this.toolBar){
				this.toolBar.removeEventListener(IndexChangeEvent.CHANGE,onSwitchContent);
			}
			else if (instance == this.switchView){
				this.switchView.removeEventListener(IndexChangeEvent.CHANGE,onSwitchView);
			}
			else if (instance == this.loginName){
				this.loginName.removeEventListener(MouseEvent.CLICK,onMySettings);
			}
		}
	}
}