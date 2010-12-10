package operate
{
	import flash.events.MouseEvent;
	
	import manage.ManagerView;
	import manage.MySettings;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.LinkButton;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.printing.FlexPrintJob;
	
	import operate.modules.note.Receipt;
	
	import org.lcf.AbstractInnerModule;
	import org.lcf.Constants;
	import org.lcf.EventListenerModel;
	import org.lcf.IComponent;
	import org.lcf.IContainer;
	import org.lcf.IModuleManager;
	import org.lcf.Overlay;
	import org.lcf.util.GeneralBundleEvent;
	import org.lcf.util.ModuleEvent;
	
	import rpc.RpcEvent;
	import rpc.RpcService;
	
	import sign.SignInfo;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.PopUpAnchor;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	
	import util.Consts;
	import util.EventTypeDefine;
	import util.ObjectNameDefine;
	import util.RemoteDate;
	
	
	public class OperatorView extends SkinnableComponent implements IComponent
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
		[SkinPart(required="true")]
		public var currentTime:Label;
		
		[SkinPart(required="true")]
		public var printContent:Group;
		
		public var mySettings:MySettings;
		
		protected var c:IContainer;
		
		public function set container(c:IContainer):void{
			this.c = c;
			this.init();
		}
		public function get preferEventListeners():Array
		{
			var minute:EventListenerModel = new EventListenerModel(EventTypeDefine.TIME_MINUTE_EVENT,onMinute);
			var print:EventListenerModel = new EventListenerModel(EventTypeDefine.PRINT,onPrint);
			return [minute,print ];
		}
		protected function onMinute(e:GeneralBundleEvent):void{
			if(this.currentTime != null)
				this.currentTime.text = "当前时间：" + (e.bundle as String).substr(0,16);
		}
		protected function onPrint(e:GeneralBundleEvent):void{
			this.printContent.removeAllElements();
			if(e.bundle is Array){
				var rs:Array = e.bundle as Array;
				for(var i:int = 0; i < rs.length; i++){
					var r:Receipt = rs[i] as Receipt;
					this.printContent.addElement(r);
				}
			}
			else if(e.bundle is Receipt){
				var rt:Receipt = e.bundle as Receipt;
				this.printContent.addElement(rt);
			}
			
			if(this.printContent != null){
				var printJob:FlexPrintJob = new FlexPrintJob();
				printJob.printAsBitmap = true;
				var printerReader:Boolean = printJob.start();
				if(printerReader){
					for(var k:int; k < this.printContent.numElements;k++){
						var receipt:Receipt = this.printContent.getElementAt(k) as Receipt;
						receipt.width = printJob.pageWidth;
						receipt.height = printJob.pageHeight;
						for(var n:int=0;n< receipt.number; n++){
							printJob.addObject(r);
						}
					}
					printJob.send();
				}
			}
		}
		public function OperatorView()
		{
			super();
			this.percentWidth = 100;
			this.percentHeight = 100;
			this.setStyle("skinClass",OperatorViewSkin);
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
			
			if(this.switchView.selectedItem["id"] == ObjectNameDefine.MANAGER_VIEW){
				this.c.dispatch(new ModuleEvent(org.lcf.Constants.OPEN_MODULE_EVENT,util.ObjectNameDefine.MANAGER_VIEW,"信息中心",new ManagerView()));
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
				this.toolBar.dataProvider = new ArrayCollection([{"url":"operate/modules/consume/ConsumePage.swf","name":"下单"},{"url":"operate/modules/consume/ConsumeHistory.swf","name":"历史订单"}]);
				this.toolBar.addEventListener(IndexChangeEvent.CHANGE,onSwitchContent);
			}
			else if (instance == this.switchView){
				this.switchView.requireSelection = true;
				this.switchView.labelField = "name";
				this.switchView.dataProvider = new ArrayCollection([{"id":ObjectNameDefine.OPERATOR_VIEW,"name":"前台交易"},{"id":ObjectNameDefine.MANAGER_VIEW,"name":"后台管理"}]);
				this.switchView.addEventListener(IndexChangeEvent.CHANGE,onSwitchView);
			}
			else if (instance == this.content){
				this.content.container.parentContainer = this.c;
				//加载RPC服务
				var info:SysInfo = c.get(SysInfo.SYSTEM_INFO) as SysInfo;
				var rpcClient:RpcService = new RpcService(info.remoteSiteUrl);
				this.content.container.put(RpcService.RPC_SERVICE, rpcClient);
				
				this.content.open("operate/modules/consume/ConsumePage.swf","下单","operate/modules/consume/ConsumePage.swf");
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